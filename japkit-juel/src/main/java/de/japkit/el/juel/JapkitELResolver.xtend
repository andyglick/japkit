package de.japkit.el.juel

import de.japkit.el.ElExtensions
import java.util.Map
import javax.el.ArrayELResolver
import javax.el.BeanELResolver
import javax.el.CompositeELResolver
import javax.el.ELContext
import javax.el.ELResolver
import javax.el.ListELResolver
import javax.el.MapELResolver
import javax.el.PropertyNotFoundException
import javax.el.ResourceBundleELResolver

/**
 * An ELResolver that resolves root properties from a map (japkit ValueStack) and that supports the extensions provided by de.japkit.el.ElExtensions.
 */
class JapkitELResolver extends ELResolver {

	val Map<String, Object> valueStack

	val ELResolver delegate
	
	static val defaultResolvers = new CompositeELResolver() => [
		add(new ArrayELResolver(true));
		add(new ListELResolver(true));
		add(new MapELResolver(true));
		add(new ResourceBundleELResolver()); 
		add(new BeanELResolver(true));
	]

	new(Map<String, ? extends Object> valueStack) {
		this.valueStack = valueStack as Map<String, Object>
		
		//MapRootResolver resolves root properties from value stack. The remaining resolvers are the default ones. 
		this.delegate = new CompositeELResolver() => [
			add(new MapRootResolver(valueStack))
			add(defaultResolvers)
		]

	}

	override getValue(ELContext context, Object base, Object property) {
		val rootProperties = valueStack

		val propertyValueFromExtensions = if (property instanceof String)
				ElExtensions.getPropertyFromExtensions(rootProperties, base, property)
			else
				null

		if (propertyValueFromExtensions?.key) {
			context.setPropertyResolved(true)
			return propertyValueFromExtensions.value
		}

		// TODO: We have a different order here compared to Groovy. In Groovy the default resolver seems to be called first !?
		try {
			return delegate.getValue(context, base, property)
		} catch (PropertyNotFoundException pnfe) {
			if(base !== null) throw pnfe;
			// The MapRootResolver throws PNFE if it cannot find a root property.
			// we retry in this case by prepending "src."
			val src = getValue(context, null, "src");
			context.setPropertyResolved(false)
			return getValue(context, src, property)
		}
	}

	override invoke(ELContext context, Object base, Object method, Class<?>[] paramTypes, Object[] params) {

		val rootProperties = valueStack

		val methodResultFromExtensions = if (method instanceof String)
				ElExtensions.invokeMethodFromExtensions(rootProperties, base, method, paramTypes, params)
			else
				null

		if (methodResultFromExtensions?.key) {
			context.setPropertyResolved(true)
			return methodResultFromExtensions.value
		}

		// TODO: We have a different order here compared to Groovy. In Groovy the default resolver seems to be called first !?
		delegate.invoke(context, base, method, paramTypes, params)
	}
	
	override getCommonPropertyType(ELContext context, Object base) {
		//Not exact for the japkit extensions !?
		delegate.getCommonPropertyType(context, base)
	}
	
	override getFeatureDescriptors(ELContext context, Object base) {
		//Not exact for the japkit extensions !?
		delegate.getFeatureDescriptors(context, base)
	}
	
	override isReadOnly(ELContext context, Object base, Object property) {
		true
	}
	
	override getType(ELContext context, Object base, Object property) {
		//Not exact for the japkit extensions !?
		delegate.getType(context, base, property)
	}
	
	override setValue(ELContext context, Object base, Object property, Object value) {
		throw new UnsupportedOperationException("Not allowed to set values.")
	}

}
