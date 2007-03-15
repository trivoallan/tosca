Selenium.prototype.assertLstmTextNotPresent = function(pattern) {
    /**
     * Tell Selenium to log a warning for specific text 
     * @param pattern The message we should look for.  
     */
    var allText = this.page().bodyText();

    var patternMatcher = new PatternMatcher(pattern);
    if (patternMatcher.strategy == PatternMatcher.strategies.glob) {
	   	if (pattern.indexOf("glob:")==0) {
		            pattern = pattern.substring("glob:".length); // strip off "glob:"
        		}
		patternMatcher.matcher = new PatternMatcher.strategies.globContains(pattern);
    }
    else if (patternMatcher.strategy == PatternMatcher.strategies.exact) {
	            pattern = pattern.substring("exact:".length); // strip off "exact:"
		return allText.indexOf(pattern) != -1;
    }
    var result = patternMatcher.matches(allText);

    if (result)
       LOG.warn("Erreur grave sur la page " + this.page().getDocument().location.href);
};


