package de.japkit.model

import de.japkit.activeannotations.FieldsFromInterface
import javax.lang.model.element.TypeElement

import static javax.lang.model.element.ElementKind.*

@FieldsFromInterface
class GenInterface extends GenTypeElement implements TypeElement{
	public static val kind = INTERFACE	
}