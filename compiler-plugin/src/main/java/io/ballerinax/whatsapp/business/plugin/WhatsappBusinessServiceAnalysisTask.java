/*
 * Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerinax.whatsapp.business.plugin;

import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.ServiceDeclarationSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import java.util.List;
import java.util.Optional;

/**
 * Analysis task that validates a service declaration attached to a WhatsApp Business
 * {@code whatsapp:Listener}.
 */
public class WhatsappBusinessServiceAnalysisTask implements AnalysisTask<SyntaxNodeAnalysisContext> {

    private final WhatsappBusinessServiceValidator serviceValidator = new WhatsappBusinessServiceValidator();

    @Override
    public void perform(SyntaxNodeAnalysisContext context) {
        for (Diagnostic diagnostic : context.semanticModel().diagnostics()) {
            if (diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR) {
                // Don't pile on top of pre-existing compile errors in this service declaration.
                return;
            }
        }
        if (!isWhatsAppBusinessService(context)) {
            return;
        }
        serviceValidator.validate(context);
    }

    private boolean isWhatsAppBusinessService(SyntaxNodeAnalysisContext context) {
        SemanticModel semanticModel = context.semanticModel();
        ServiceDeclarationNode serviceDeclarationNode = (ServiceDeclarationNode) context.node();
        Optional<Symbol> symbol = semanticModel.symbol(serviceDeclarationNode);
        if (symbol.isEmpty()) {
            return false;
        }
        ServiceDeclarationSymbol serviceDeclarationSymbol = (ServiceDeclarationSymbol) symbol.get();
        List<TypeSymbol> listeners = serviceDeclarationSymbol.listenerTypes();
        for (TypeSymbol listener : listeners) {
            if (isWhatsAppBusinessListener(listener)) {
                return true;
            }
        }
        return false;
    }

    private boolean isWhatsAppBusinessListener(TypeSymbol listener) {
        if (listener.typeKind() == TypeDescKind.UNION) {
            for (TypeSymbol member : ((UnionTypeSymbol) listener).memberTypeDescriptors()) {
                Optional<ModuleSymbol> module = member.getModule();
                if (module.isPresent() && PluginUtils.isWhatsAppBusinessModule(module.get())) {
                    return true;
                }
            }
            return false;
        }
        Optional<ModuleSymbol> module = listener.getModule();
        return module.isPresent() && PluginUtils.isWhatsAppBusinessModule(module.get());
    }
}
