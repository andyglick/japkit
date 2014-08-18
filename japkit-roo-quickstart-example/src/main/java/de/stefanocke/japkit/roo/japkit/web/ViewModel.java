package de.stefanocke.japkit.roo.japkit.web;

import javax.lang.model.element.Modifier;

import de.stefanocke.japkit.metaannotations.Annotation;
import de.stefanocke.japkit.metaannotations.Clazz;
import de.stefanocke.japkit.metaannotations.Field;
import de.stefanocke.japkit.metaannotations.Getter;
import de.stefanocke.japkit.metaannotations.Properties;
import de.stefanocke.japkit.metaannotations.Var;
import de.stefanocke.japkit.metaannotations.classselectors.AnnotatedClass;

@Clazz(nameSuffixToRemove = "ViewModelDef", nameSuffixToAppend = "ViewModel", modifier = Modifier.ABSTRACT, vars = @Var(
		name = "properties", propertyFilter = @Properties(sourceClass = FormBackingObject.class)))
@Field(src="properties", manualOverrides= AnnotatedClass.class,  
	annotations = @Annotation(src="#{src.field}", copyAnnotationsFromPackages = "*") , getter=@Getter)
public @interface ViewModel {
	boolean shadow() default false;

	Class<?> formBackingObject();
}
