package de.stefanocke.japkit.processor

import de.stefanocke.japkit.gen.GenAnnotationMirror
import de.stefanocke.japkit.gen.GenTypeElement
import de.stefanocke.japkit.support.ExtensionRegistry
import de.stefanocke.japkit.support.RuleFactory
import java.util.ArrayList
import java.util.Collections
import java.util.List
import javax.lang.model.element.AnnotationMirror
import javax.lang.model.element.TypeElement
import de.stefanocke.japkit.metaannotations._Annotation

/**
 * To add additional annotation mappings to the ones defined by @GenerateClass.
 */
class AnnotationGenerator extends MemberGeneratorSupport implements MemberGenerator {
	
val extension RuleFactory =  ExtensionRegistry.get(RuleFactory)

	override createMembers(TypeElement membersClass, TypeElement annotatedClass, GenTypeElement generatedClass, AnnotationMirror annotation,
		AnnotationMirror annotationMappingAnnotation) {
		
		//Das lässt sich sicher optimieren indem eine Variante der Methode angeboten wird, die mehrere AMs entgegen nimmt.
		//Die default impl würde einfach eine schleife drehen. 
		//Einzelne MemberGeneraatoren wie dieser hier könnten das aber überschreiben.
		val amr = Collections.singleton(annotationMappingAnnotation.createAnnotationMappingRule)
		generatedClass.annotationMirrors = mapAnnotations(amr, 
			new ArrayList(generatedClass.annotationMirrors as List<GenAnnotationMirror>)
		)
	}

	override getSupportedMetaAnnotation() {
		_Annotation.name
	}
	
	override createMemberRule(TypeElement membersClass, AnnotationMirror metaAnnotationToBeProcessed) {
		throw new UnsupportedOperationException("Not used here")
	}

}
