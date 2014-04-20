package de.stefanocke.japkit.metaannotations;

import java.lang.annotation.Annotation;

public @interface Var {
	String name();

	/**
	 * If true, the EL-Variabale is not evaluated immediately. Instead, it is
	 * put as a function on the value stack and can be evaluated later by
	 * calling its eval, filter or map method. The parameter to this methods must
	 * be the element or list of elements to apply the function for.
	 * 
	 * @return
	 */
	boolean isFunction() default false;

	/**
	 * If this is set, the current trigger annotation value with this name is
	 * retrieved. If it is set (TODO: What does this exactly mean?), it is used
	 * as value for the variable and the expression, property filter or type query won't be evaluated.
	 * 
	 * @return the trigger annotation value name
	 */
	String triggerAV() default "";

	/**
	 * If this is true and {@link #triggerAV()} is set, the annotation value
	 * with that name in the shadow annotation will be set to the value of the
	 * EL Variable. TODO: Is the really a property of the Var? Maybe, we should
	 * support this only for the case, where the @Var annotation is put directly
	 * on the annotation value declaration. (This is nicer anyway...). But then
	 * there is the Eclipse-ordering issue again...
	 * 
	 * @return
	 */
	boolean setInShadowAnnotation() default false;

	/**
	 * The expression to be evaluated.
	 * 
	 * @return
	 */
	String expr() default "";

	/**
	 * The language for the expression.
	 * @return
	 */
	String lang() default "";

	Class<?> type() default Object.class;

	/**
	 * If this value is set, the expression is ignored and the variable is a
	 * list of properties instead, according to the given filter criteria.
	 * 
	 * @return
	 */
	Properties[] propertyFilter() default {};

	/**
	 * If this value is set, the expression is ignored and a type query is executed instead.
	 * 
	 * @return
	 */
	TypeQuery[] typeQuery() default {};

	/**
	 * If set, and expr is set, the matcher is applied to the result of
	 * expression and the result (true or false) is put on value stack. 
	 */
	Matcher[] matcher() default {};

	/**
	 * If set, the according annotation of the result of the expression,
	 * property filter or type query is retrieved. This is possible for
	 * Elements, Collection of Elements, Types and collections of types.
	 * 
	 * @return
	 */
	Class<? extends Annotation>[] annotation() default {};

	@interface List {
		Var[] value();
	}
}
