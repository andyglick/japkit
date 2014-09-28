package de.stefanocke.japkit.roo.japkit.domain;

import de.stefanocke.japkit.metaannotations.classselectors.ClassSelector;
import de.stefanocke.japkit.metaannotations.classselectors.ClassSelectorKind;

@ClassSelector(kind=ClassSelectorKind.EXPR, expr="#{genClass.superclass}") class GeneratedClassSuperClass {}