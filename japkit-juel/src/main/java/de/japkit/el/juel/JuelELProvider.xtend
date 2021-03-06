package de.japkit.el.juel

import de.japkit.el.ELProvider
import de.japkit.el.ELProviderException
import de.japkit.el.ValueStack
import de.japkit.services.ExtensionRegistry
import java.io.Writer
import java.net.URL
import javax.el.ELContext
import javax.el.ELException
import javax.el.ExpressionFactory
import java.util.List

class JuelELProvider implements ELProvider {
	val ExpressionFactory ef = ExtensionRegistry.get(ExpressionFactory, [|
		val oldCCL = Thread.currentThread().contextClassLoader
		try {
			// ExpressionFactory.newInstance uses ContextClassLoader to load the ExpressionFactoryImpl
			// In case of Javac, the CCL does not contain the annotation processor class path but something like the compiler classpath (?) instead.
			// See also  https://community.oracle.com/thread/1184129 
			// So, we temporary set the CCL to something useful.
			Thread.currentThread().contextClassLoader = JuelELProvider.classLoader
			ExpressionFactory.newInstance
		} finally {
			Thread.currentThread().contextClassLoader = oldCCL
		}
	])
	
	val methodCache = new MethodCache

	override eval(ValueStack vs, String expr, Class<?> expectedType, String language, List<String> importedClasses) {
		//importedClasses are ignored since not supported by EL2
		try {
			val context = createElContext(vs)
			eval(context, expr, expectedType)
		} catch (ELException e) {
			if(e.cause !== null && !(e.cause instanceof ELException)){
				//Unwrap all Exceptions that are likely not caused by human mistakes.
				//This will lead to better error reporting (stack trace)
				throw e.cause
			}
			throw new ELProviderException(e)
		}
	}

	def private createElContext(ValueStack vs) {
		val context = new JapkitELContext(vs, methodCache);

		// Force the use of the same context. For example, when the ELResolver internally calls getExpressionFactory(context)
		// Otherwise we run into some class loading issues..
		context.putContext(ExpressionFactory, ef)
		context

	}

	def private <T> T eval(ELContext context, String expr, Class<T> expectedType) {
		expectedType.cast(ef.createValueExpression(context, expr, expectedType).getValue(context))
	}

	override getSupportedLanguages() {
		#["JavaEL"]
	}

	override getSupportedTemplateLanguages() {
		emptyList
	}

	override write(Writer writer, URL templateUrl, ValueStack vs, String templateLanguage, Long templateLastModified) {
		throw new UnsupportedOperationException("Java EL Provider does not support templates.")
	}

}
