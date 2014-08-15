package de.stefanocke.japkit.metaannotations;

import javax.lang.model.element.Element;

import de.stefanocke.japkit.metaannotations.classselectors.None;

public @interface Param {
	//TODO: Do we really want to allow overriding for such an "inner" annotation as @Param ?
	String _prefix() default "<methodParam>";
	
	
	/**
	 * An expression to determine the source object for generating this element.
	 * The source element is available as "src" in expressions and is used in
	 * matchers and other rules. If the src expression is not set, the src
	 * element of the parent element is used (usually the enclosing element).
	 * <p>
	 * If this expression results in an Iterable, each object provided by the
	 * Iterator is use as source object. That is, the element is generated
	 * multiple times, once for each object given by the iterator.
	 * 
	 * @return
	 */
	String src() default "";

	/**
	 * 
	 * @return the language of the src expression. Defaults to Java EL.
	 */
	String srcLang() default "";
	
	/**
	 * By default, the current source object has the name "src" on the value stack.
	 * If this annotation value is set, the source object will additionally provided under the given name.  
	 * 
	 * @return the name of the source variable
	 */
	String srcVar() default "";
	
	/**
	 * How to map annotations of the source element (???) to the method parameter
	 * <p>
	 * 
	 * @return the annotation mappings
	 */
	Annotation[] annotations() default {};
	
	/** name of the parameter*/
	String name() default "";
	
	/**
	 * For more complex cases: a Java EL expression to generate the name of the
	 * parameter. 
	 * 
	 * @return
	 */
	String nameExpr() default "";

	/**
	 * 
	 * @return the language of the name expression. Defaults to Java EL.
	 */
	String nameLang() default "";
	
	
	Class<?> type() default None.class;
	
	Class<?>[] typeArgs() default {};
		
}
