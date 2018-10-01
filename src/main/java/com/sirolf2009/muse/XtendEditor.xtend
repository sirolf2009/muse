package com.sirolf2009.muse

import java.io.Closeable
import java.time.Duration
import java.util.Collection
import java.util.Collections
import java.util.Optional
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.regex.Pattern
import javafx.concurrent.Task
import org.fxmisc.richtext.CodeArea
import org.fxmisc.richtext.LineNumberFactory
import org.fxmisc.richtext.model.StyleSpans
import org.fxmisc.richtext.model.StyleSpansBuilder

class XtendEditor extends CodeArea implements Closeable {
	
	static val KEYWORDS = #[
		"abstract", "assert", "boolean", "break", "byte",
        "case", "catch", "char", "class", "const",
        "continue", "default", "do", "double", "else",
        "enum", "extends", "final", "finally", "float",
        "for", "goto", "if", "implements", "import",
        "instanceof", "int", "interface", "long", "native",
        "new", "package", "private", "protected", "public",
        "return", "short", "static", "strictfp", "super",
        "switch", "synchronized", "this", "throw", "throws",
		"transient", "try", "void", "volatile", "while", "val", "var"
	]
	
	static val String KEYWORD_PATTERN = "\\b(" + String.join("|", KEYWORDS) + ")\\b";
    static val String PAREN_PATTERN = "\\(|\\)";
    static val String BRACE_PATTERN = "\\{|\\}";
    static val String BRACKET_PATTERN = "\\[|\\]";
    static val String SEMICOLON_PATTERN = "\\;";
    static val String STRING_PATTERN = "\"([^\"\\\\]|\\\\.)*\"";
    static val String COMMENT_PATTERN = "//[^\n]*" + "|" + "/\\*(.|\\R)*?\\*/";

    static val Pattern PATTERN = Pattern.compile(
            "(?<KEYWORD>" + KEYWORD_PATTERN + ")"
            + "|(?<PAREN>" + PAREN_PATTERN + ")"
            + "|(?<BRACE>" + BRACE_PATTERN + ")"
            + "|(?<BRACKET>" + BRACKET_PATTERN + ")"
            + "|(?<SEMICOLON>" + SEMICOLON_PATTERN + ")"
            + "|(?<STRING>" + STRING_PATTERN + ")"
            + "|(?<COMMENT>" + COMMENT_PATTERN + ")"
	)
	val ExecutorService executor
	
	new() {
		getStylesheets().add(XtendEditor.getClassLoader().getResource("xtend-keywords.css").toExternalForm())
		executor = Executors.newSingleThreadExecutor()
		setParagraphGraphicFactory(LineNumberFactory.get(this))
		multiPlainChanges()
                .successionEnds(Duration.ofMillis(500))
                .supplyTask[computeHighlightingAsync()]
                .awaitLatest(multiPlainChanges())
                .filterMap[
                    if(isSuccess()) {
                        return Optional.of(get())
                    } else {
                        getFailure().printStackTrace()
                        return Optional.empty()
                    }
                ].subscribe[applyHighlighting]
	}
	
	override close() {
        executor.shutdown()
    }

    def Task<StyleSpans<Collection<String>>> computeHighlightingAsync() {
        val text = getText()
        val task = new Task<StyleSpans<Collection<String>>>() {
            override call() throws Exception {
                return computeHighlighting(text)
            }
        };
        executor.execute(task);
        return task;
    }

    def applyHighlighting(StyleSpans<Collection<String>> highlighting) {
        setStyleSpans(0, highlighting)
    }

    def static StyleSpans<Collection<String>> computeHighlighting(String text) {
        val matcher = PATTERN.matcher(text)
        var lastKwEnd = 0
        val spansBuilder = new StyleSpansBuilder()
        while(matcher.find()) {
            val styleClass =
                    if(matcher.group("KEYWORD") !== null) "keyword" else
                    if(matcher.group("PAREN") !== null) "paren" else
                    if(matcher.group("BRACE") !== null) "brace" else
                    if(matcher.group("BRACKET") !== null) "bracket" else
                    if(matcher.group("SEMICOLON") !== null) "semicolon" else
                    if(matcher.group("STRING") !== null) "string" else
                    if(matcher.group("COMMENT") !== null) "comment" else
                    null
            spansBuilder.add(Collections.emptyList(), matcher.start() - lastKwEnd);
            spansBuilder.add(Collections.singleton(styleClass), matcher.end() - matcher.start());
            lastKwEnd = matcher.end();
        }
        spansBuilder.add(Collections.emptyList(), text.length() - lastKwEnd);
        return spansBuilder.create();
}
	
}