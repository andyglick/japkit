package de.japkit.model

import de.japkit.annotations.Order
import de.japkit.metaannotations.Clazz
import de.japkit.metaannotations.classselectors.ClassSelector
import de.japkit.services.ElementsExtensions
import de.japkit.services.ExtensionRegistry
import de.japkit.services.TypeElementNotFoundException
import java.util.ArrayList
import java.util.List
import javax.lang.model.element.AnnotationMirror
import javax.lang.model.element.AnnotationValue
import javax.lang.model.element.Element
import javax.lang.model.element.ElementKind
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.Modifier
import javax.lang.model.element.TypeElement
import javax.lang.model.element.VariableElement
import javax.lang.model.type.TypeMirror
import de.japkit.rules.TypeResolver

class GenExtensions {
	val transient extension ElementsExtensions = ExtensionRegistry.get(ElementsExtensions)
	val transient extension TypeResolver = ExtensionRegistry.get(TypeResolver)
	
	def createOverride(ExecutableElement m, CodeBody b) {
		//TODO: Check, if method can be overridden?
		copyFrom(m) => [
			if (m.enclosingElement.kind == ElementKind.INTERFACE) {
				addModifier(Modifier.PUBLIC)			
			}
			body = b			
		]

	}

	def copyFrom(ExecutableElement m) {
		copyFrom(m, false)
	}
////copy all but enclosing type
//	def copyFrom(ExecutableElement m, boolean copyAnnotations, (GenMethod)=>void modifications) {
//		val method = copyFrom(m, copyAnnotations)
//		modifications.apply(method);
//		method
//	}
	
	def copyFrom(ExecutableElement m, boolean copyAnnotations){
		copyFrom(m, copyAnnotations, [TypeMirror t | t]) as GenMethod
	}
	
	
	
	
	
	//copy all but enclosing type
	def dispatch copyFrom(ExecutableElement m, boolean copyAnnotations, (TypeMirror)=>TypeMirror typeTransformer) {

		//TODO: Optionally copy Annotations?
		val result = if(m.kind == ElementKind.METHOD){ 
			new GenMethod(m.simpleName) 
			
		} else if(m.kind== ElementKind.CONSTRUCTOR) {
			new GenConstructor
		} else {
			throw new IllegalArgumentException('''Copying «m» not supported.''');
		}
		
		result => [
			if (copyAnnotations) {
				annotationMirrors = m.copyAnnotations
			}
			if(m.kind == ElementKind.METHOD){
				returnType = typeTransformer.apply(m.returnType)?.resolveType  //resolveType is called since we don't want to copy ErrorTypes
			
			}
			setThrownTypes(m.thrownTypes.map[typeTransformer.apply(it)])
			setTypeParameters(m.typeParameters.map[tp|getOrCreateTypeParameter(tp)])
			setVarArgs(m.varArgs)
			setParameters(copyParametersFrom(m, copyAnnotations, typeTransformer))
			modifiers = m.modifiers
		]
	}
	
	def copyParametersFrom(ExecutableElement m, boolean copyAnnotations){
		copyParametersFrom(m, copyAnnotations, [TypeMirror t | t]) 
	}
	
	def copyParametersFrom(ExecutableElement method, boolean copyAnnotations, (TypeMirror)=>TypeMirror typeTransformer) {
		method.parametersWithSrcNames.map [ p |
			copyParamFrom(p, copyAnnotations, typeTransformer)
		]
	}
	
	def copyParamFrom(VariableElement p, boolean copyAnnotations, (TypeMirror)=>TypeMirror typeTransformer) {
		new GenParameter(p.simpleName, typeTransformer.apply(p.asType)) => [
			if (copyAnnotations) {
				annotationMirrors = p.copyAnnotations
			}]
	}
	
	//Copy a field 
	def dispatch copyFrom(VariableElement ve, boolean copyAnnotations, (TypeMirror)=>TypeMirror typeTransformer) {
		new GenField(ve.simpleName, typeTransformer.apply(ve.asType?.resolveType)) => [
			modifiers = ve.modifiers
			if (copyAnnotations) {
				annotationMirrors = ve.copyAnnotations
			}]
	}
	
	def asMemberOf(ExecutableElement m, TypeElement type) {
		copyFrom(m) => [
			enclosingElement = m.enclosingElement
			resolveContainedTypeVariables(type as GenTypeElement)
		]
	}
	
	def asInterfaceMethod(ExecutableElement m) {
		copyFrom(m) => [
			modifiers = emptySet //TODO: Make configurable whether to use "public abstract"
			body = null
		]
	}
	
	def asAbstractMethod(ExecutableElement m) {
		copyFrom(m) => [
			addModifier(Modifier.ABSTRACT)
			body = null
		]
	}
	
	//do never copy japkit meta-annotations
	val japkitAnnotationPackages = #{Clazz.package.name, Order.package.name, ClassSelector.package.name}
	
	def boolean isJapkitAnnotation(AnnotationMirror am){
		japkitAnnotationPackages.contains(am.annotationAsTypeElement.package.qualifiedName.toString)
	}
	
	public val isNoJapkitAnnotationFilter = [AnnotationMirror am | 
		!(am.isJapkitAnnotation)
	]	
	
	//Copies all annotations but Japkit metaannotations.
	def copyAnnotations(Element src){
		src.copyAnnotations(isNoJapkitAnnotationFilter, [it])
	}
	
	def copyAnnotations(Element src, (AnnotationMirror)=>boolean filter, (Object)=>Object valueTransformer){
		new ArrayList(src.annotationMirrors.filter(filter).map[copy(valueTransformer)].toList)
	}
	
	
	def static GenAnnotationMirror copy(AnnotationMirror am){
		copy(am, [it])
	}
	
	def static GenAnnotationMirror copy(AnnotationMirror am, (Object)=>Object valueTransformer ){
		new GenAnnotationMirror(am.annotationType) => [ 
			am.elementValues.entrySet.forEach[avEntry | setValue(avEntry.key.simpleName.toString, avEntry.value.copy(valueTransformer))]
		]
	}
	
	def static GenAnnotationValue copy(AnnotationValue av,(Object)=>Object valueTransformer ){
		val extension ElementsExtensions = ExtensionRegistry.get(ElementsExtensions)	
		new GenAnnotationValue(av.valueWithErrorHandling.copyAvValue(valueTransformer))
	}
	
	def static dispatch copyAvValue(List<? extends AnnotationValue> values, (Object)=>Object valueTransformer ){
		new ArrayList(values.map[copy(valueTransformer)])
	}
	
	def static dispatch copyAvValue(AnnotationMirror v, (Object)=>Object valueTransformer ){
		v.copy(valueTransformer)
	}
	
	def static dispatch copyAvValue(Object v, (Object)=>Object valueTransformer ){
		
		//In Eclipse, annotation values with errors are returned as "<error>". F.e. constant values that use not-(yet)-existing types. 
		//In Javac this is also the case if the AV is an unknown type itself. (In eclipse we get an error type in that case.) 
		if(v == "<error>" ){
			throw new TypeElementNotFoundException();
		}
		
		return valueTransformer.apply(v)	
		
	}
	
}