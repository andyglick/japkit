package de.stefanocke.japkit.support

import de.stefanocke.japkit.gen.CodeBody
import de.stefanocke.japkit.gen.GenField
import javax.lang.model.element.AnnotationMirror
import javax.lang.model.element.VariableElement
import javax.lang.model.type.TypeMirror

@Data
class FieldRule extends MemberRuleSupport<VariableElement, GenField> {
	extension GetterSetterRules = ExtensionRegistry.get(GetterSetterRules)
	
	(GenField)=>CodeBody initCodeRule
	
	()=>TypeMirror typeRule
	
	new(AnnotationMirror metaAnnotation, VariableElement template) {
		super(metaAnnotation, template)
		_initCodeRule = createInitCodeRule	
		_typeRule = createTypeRule
		
		addGetterRule
		addSetterRule
		
	}
	
	def protected addGetterRule() {
		addDependentMemberRule(createGetterRuleFromGetterAV(metaAnnotation, null))
	}
	
	def protected addSetterRule() {
		addDependentMemberRule(createSetterRuleFromSetterAV(metaAnnotation, null))
	}
	
	
	protected def ()=>TypeMirror createTypeRule() {
		ru.createTypeRule(metaAnnotation, template?.asType, null)
	}
	
	override protected createMember(String name) {
		new GenField(name, null)
	}
	
	protected override applyRulesAfterCreation(GenField member) {
		super.applyRulesAfterCreation(member)
		member.type = typeRule.apply
		
		member.constantExpr = _initCodeRule.apply(member)
	}
	
	def protected (GenField)=>CodeBody createInitCodeRule(){
		val cr = new CodeRule(metaAnnotation, template, "init");
		[genElement | CodeRule.getAsCodeBody(genElement, cr)]
	}

}
