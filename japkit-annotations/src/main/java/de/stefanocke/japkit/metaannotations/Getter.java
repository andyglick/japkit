package de.stefanocke.japkit.metaannotations;

import javax.lang.model.element.Modifier;

public @interface Getter {
	Matcher[] activation() default {};
	
	Modifier[] modifiers() default { Modifier.PUBLIC };

	_Annotation[] annotations() default {};
	
	/**
	 * 
	 * @return true means, the "get" / "is" prefix is omitted.
	 */
	boolean fluent() default false;
	
	/**
	 * Names of code fragments to surround the return expression.
	 */
	String[] surroundReturnExprFragments() default {};
	
	/**
	 * 
	 * @return names of the fragments to surround the generated code body.
	 */
	String[] surroundingFragments() default{};
	
	/**
	 * 
	 * @return names of the fragments to be inserted before the generated code body.
	 */
	String[] beforeFragments() default{};
	
	/**
	 * 
	 * @return names of the fragments to be inserted before the generated code body.
	 */
	String[] afterFragments() default{};
	
	
	/**
	 * 
	 * @return an expression to create the JavaDoc comment
	 */
	String commentExpr() default "";
	
	/**
	 * 
	 * @return the expression language for commentExpr
	 */
	String commentLang() default "";
}
