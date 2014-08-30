package de.stefanocke.japkit.support

import de.stefanocke.japkit.gen.GenAnnotationMirror
import de.stefanocke.japkit.gen.GenExtensions
import de.stefanocke.japkit.metaannotations.AnnotationMode
import de.stefanocke.japkit.metaannotations.DefaultAnnotation
import de.stefanocke.japkit.support.el.ELSupport
import java.util.List
import java.util.Map
import java.util.Set
import javax.annotation.processing.ProcessingEnvironment
import javax.lang.model.element.AnnotationMirror
import javax.lang.model.element.Element
import javax.lang.model.type.DeclaredType

import static de.stefanocke.japkit.metaannotations.AnnotationMode.*

@Data
class AnnotationMappingRule extends AbstractRule{
	val extension ElementsExtensions jme = ExtensionRegistry.get(ElementsExtensions)
	val extension ProcessingEnvironment procEnv = ExtensionRegistry.get(ProcessingEnvironment)
	//val extension RoundEnvironment roundEnv = ExtensionRegistry.get(RoundEnvironment)
	val extension ELSupport elSupport = ExtensionRegistry.get(ELSupport)
	val extension MessageCollector messageCollector = ExtensionRegistry.get(MessageCollector)
	val extension AnnotationExtensions annotationExtensions = ExtensionRegistry.get(AnnotationExtensions)
	val extension RuleFactory =  ExtensionRegistry.get(RuleFactory)
	val extension TypesExtensions = ExtensionRegistry.get(TypesExtensions)
	val extension RuleUtils =  ExtensionRegistry.get(RuleUtils)

	String id
	()=>boolean activationRule
	DeclaredType targetAnnotation
	AnnotationValueMappingRule[] valueMappings
	AnnotationMode mode

	Set<String> copyAnnotationsFqns
	String[] copyAnnotationsFromPackages
	boolean setShadowOnTriggerAnnotations
	((Object)=>Object)=>Iterable<Object> scopeRule


	/**
	 * Adds the annotation mapped by this rule.
	 * 
	 * @param annotations the annotations generated so far for the element
	 * @param srcElement the source element
	 */
	def void mapOrCopyAnnotations(List<GenAnnotationMirror> annotations, Map<String, AnnotationMappingRule> mappingsWithId) {
		inRule[
			if (!activationRule.apply) {
				return null
			}
			
			scopeRule.apply[
				copyAnnotations(annotations)
				
		
				if(!DefaultAnnotation.name.equals(targetAnnotation?.qualifiedName)){
					mapAnnotation(annotations, mappingsWithId)	
				}
				null //TODO.
			]
		
		]

	}
	
	def private copyAnnotations(List<GenAnnotationMirror> annotations) {
		if(!copyAnnotationsFqns.empty || !copyAnnotationsFromPackages.empty){
			currentSrcElement.annotationMirrors.filter[shallCopyAnnotation].forEach[
				try{
					annotations.add(copyAnnotation)			
				} catch(ProcessingException e){
					messageCollector.reportError(e)
				}
			]
		}
	}
	
	private def copyAnnotation(AnnotationMirror am) {
		val extension GenerateClassContext = ExtensionRegistry.get(GenerateClassContext)
		GenExtensions.copy(am) => [
				if(it.annotationType.qualifiedName==currentTriggerAnnotation.annotationType.qualifiedName){
					putShadowAnnotation(it)
				}
			//TODO: Ist this still necessary here? 
				if(setShadowOnTriggerAnnotations){setShadowIfAppropriate}
			]
	}
	
	def private boolean shallCopyAnnotation(AnnotationMirror am){
		!ExtensionRegistry.get(GenExtensions).isJapkitAnnotation(am) && (
		copyAnnotationsFqns.contains(am.annotationType.qualifiedName) 
		|| {
			val packageFqn = am.annotationType.asElement.package.qualifiedName.toString
			copyAnnotationsFromPackages.exists[
				equals(packageFqn) ||
				equals("*") || 
				endsWith(".*") && packageFqn.equals(substring(0, it.length-2)) || 
				endsWith(".**") && packageFqn.startsWith(substring(0, it.length-3))
			]
		})
	}
	
	def private void mapAnnotation(List<GenAnnotationMirror> annotations, Map<String, AnnotationMappingRule> mappingsWithId) {
		
		
		var am = annotations.findFirst[hasFqn(targetAnnotation.qualifiedName)]
		
		if (am == null) {
			if (mode == REMOVE) {
				return
			} else {
				am = new GenAnnotationMirror(targetAnnotation)
				annotations.add(am)
			}
		} else {
			if(id.nullOrEmpty){
				switch (mode) {
					case ERROR_IF_EXISTS:
						throw new ProcessingException(
							'''The annotation «targetAnnotation.qualifiedName» was already generated by another rule and the mapping mode is «mode».''',
							if(currentSrc instanceof Element) currentSrcElement)
					case REPLACE: {
						annotations.remove(am)
						am = new GenAnnotationMirror(targetAnnotation)
						annotations.add(am)
					}
					case REMOVE: {
						annotations.remove(am);
						return
					}
					case MERGE: { /**Reuse existing one */
					}
					case IGNORE:
						return
					default:
						throw new ProcessingException('''Annotation mapping mode «mode» is not supported.''', if(currentSrc instanceof Element) currentSrcElement)
				}
			
			} else {
				//The AnnotationMapping is used from an annotation value mapping. Just ignore the mapping mode and create a new annotation.
				am = new GenAnnotationMirror(targetAnnotation)
				annotations.add(am)
			}
		
		}
		
		val anno = am
		
		
		valueStack.put("targetAnnotation", anno)
	
		anno => [
			valueMappings.forEach [ vm |
				try {
					setValue(vm.name,
						[ avType |
							vm.mapAnnotationValue(anno, avType, mappingsWithId)
						])
		
				} catch (RuntimeException e) {
		
					messageCollector.reportError('''
							Could not set annotation value «vm.name» for mapped annotation «it?.annotationType?.qualifiedName».
							Cause: «e.message»
						''', e, if(currentSrc instanceof Element) currentSrcElement, null, null)
				}
			]
		]
		
		
	}
	


	new(AnnotationMirror am) {
		super(am, null)
		_id = am.value("id", String)
		_activationRule = createActivationRule(am, null)
		_targetAnnotation = am.value("targetAnnotation", DeclaredType)
		_valueMappings = am.value("values", typeof(AnnotationMirror[])).map[
			new AnnotationValueMappingRule(it)]
		_mode = am.value("mode", AnnotationMode)
		
		_copyAnnotationsFqns = am.value("copyAnnotations", typeof(DeclaredType[])).map[qualifiedName].toSet
		_copyAnnotationsFromPackages = am.value("copyAnnotationsFromPackages", typeof(String[]))
		_setShadowOnTriggerAnnotations = am.value("setShadowOnTriggerAnnotations", Boolean)
		_scopeRule = createScopeRule(am, null, null)
	}
	
	
	
}
