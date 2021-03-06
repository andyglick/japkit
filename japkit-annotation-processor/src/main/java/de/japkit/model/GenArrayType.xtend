package de.japkit.model

import de.japkit.activeannotations.FieldsFromInterface
import de.japkit.activeannotations.Required
import javax.lang.model.type.ArrayType
import javax.lang.model.type.TypeKind
import javax.lang.model.type.TypeMirror
import javax.lang.model.type.TypeVisitor

@FieldsFromInterface
class GenArrayType extends GenTypeMirror implements ArrayType {
	public static val kind = TypeKind.ARRAY
	

	@Required
	TypeMirror componentType

	
	override toString(){
		'''«componentType» []'''
	}	
	
	override <R, P> accept(TypeVisitor<R,P> v, P p) {
		v.visitArray(this, p)
	}

}