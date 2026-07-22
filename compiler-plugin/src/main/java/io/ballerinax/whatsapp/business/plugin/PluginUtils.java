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
import io.ballerina.compiler.api.symbols.MethodSymbol;
import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.Qualifier;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.syntax.tree.FunctionDefinitionNode;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import io.ballerina.tools.diagnostics.Location;

import java.util.Optional;

/**
 * Shared helpers for the WhatsApp Business compiler plugin.
 */
final class PluginUtils {

    private PluginUtils() {
    }

    static Diagnostic getDiagnostic(PluginConstants.CompilationErrors error, DiagnosticSeverity severity,
            Location location, Object... args) {
        String message = args.length == 0 ? error.getError() : String.format(error.getError(), args);
        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(error.getErrorCode(), message, severity);
        return DiagnosticFactory.createDiagnostic(diagnosticInfo, location);
    }

    static Optional<MethodSymbol> getMethodSymbol(SyntaxNodeAnalysisContext context,
            FunctionDefinitionNode functionDefinitionNode) {
        SemanticModel semanticModel = context.semanticModel();
        Optional<Symbol> symbol = semanticModel.symbol(functionDefinitionNode);
        return symbol.map(value -> (MethodSymbol) value);
    }

    static boolean isRemoteFunction(MethodSymbol methodSymbol) {
        return methodSymbol.qualifiers().contains(Qualifier.REMOTE);
    }

    static boolean isWhatsAppBusinessModule(ModuleSymbol moduleSymbol) {
        return moduleSymbol.id().moduleName().equals(PluginConstants.PACKAGE_PREFIX) &&
                moduleSymbol.id().orgName().equals(PluginConstants.PACKAGE_ORG);
    }
}
