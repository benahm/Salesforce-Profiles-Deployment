/*
* author : benahm
* description : utility class (code from Apache StringUtils)
*/
class Utility {
    private static final String EMPTY = '';
    private static final int INDEX_NOT_FOUND = -1;

    /**
    * @description : Checks if a CharSequence is empty ("") or null.
    * @param : string to check 
    */
    def static boolean isEmpty(String str) {
        return str == null || str.length() == 0;
    }
    /**
     * @description Gets the substring before the first occurrence of a separator.
     * @param str  the String to get a substring from, may be null
     * @param separator  the String to search for, may be null
     * @return the substring before the first occurrence of the separator,
     */
    def static String substringBefore(final String str, final String separator) {
        if (isEmpty(str) || separator == null) {
            return str;
        }
        if (separator.isEmpty()) {
            return EMPTY;
        }
        final int pos = str.indexOf(separator);
        if (pos == INDEX_NOT_FOUND) {
            return str;
        }
        return str.substring(0, pos);
    }

    /**
     * @description Gets the substring after the first occurrence of a separator.
     * @param str  the String to get a substring from, may be null
     * @param separator  the String to search for, may be null
     * @return the substring after the first occurrence of the separator,
     */
    def static String substringAfter(final String str, final String separator) {
        if (isEmpty(str)) {
            return str;
        }
        if (separator == null) {
            return EMPTY;
        }
        final int pos = str.indexOf(separator);
        if (pos == INDEX_NOT_FOUND) {
            return EMPTY;
        }
        return str.substring(pos + separator.length());
    }

    /**
     * @description Gets the substring after the last occurrence of a separator.
     * @param str  the String to get a substring from, may be null
     * @param separator  the String to search for, may be null
     * @return the substring after the last occurrence of the separator,
     */
    def static String substringBeforeLast(final String str, final String separator) {
        if (isEmpty(str) || isEmpty(separator)) {
            return str;
        }
        final int pos = str.lastIndexOf(separator);
        if (pos == INDEX_NOT_FOUND) {
            return str;
        }
        return str.substring(0, pos);
    }

    /**
     * @description Gets the substring last the last occurrence of a separator.
     * @param str  the String to get a substring from, may be null
     * @param separator  the String to search for, may be null
     * @return the substring last the last occurrence of the separator,
     */
    def static String substringAfterLast(final String str, final String separator) {
        if (isEmpty(str)) {
            return str;
        }
        if (isEmpty(separator)) {
            return EMPTY;
        }
        final int pos = str.lastIndexOf(separator);
        if (pos == INDEX_NOT_FOUND || pos == str.length() - separator.length()) {
            return EMPTY;
        }
        return str.substring(pos + separator.length());
    }

    /**
     * @description Gets the String that is nested in between two instances of the
     * same String
     * @param str  the String containing the substring, may be null
     * @param tag  the String before and after the substring, may be null
     * @return the substring, {@code null} if no match
     */
    def static String substringBetween(final String str, final String tag) {
        return substringBetween(str, tag, tag);
    }

    /**
     * @description Gets the String that is nested in between two instances of the
     * same String
     * @param str  the String containing the substring, may be null
     * @param tag  the String before and after the substring, may be null
     * @param close  the String after the substring, may be null
     * @return the substring, {@code null} if no match
     */
    def static String substringBetween(final String str, final String open, final String close) {
        if (str == null || open == null || close == null) {
            return null;
        }
        final int start = str.indexOf(open);
        if (start != INDEX_NOT_FOUND) {
            final int end = str.indexOf(close, start + open.length());
            if (end != INDEX_NOT_FOUND) {
                return str.substring(start + open.length(), end);
            }
        }
        return null;
    }

    /**
     * @description Removes a substring only if it is at the beginning of a source string,
     * otherwise returns the source string.
     * @param str  the source String to search, may be null
     * @param remove  the String to search for and remove, may be null
     * @return the substring with the string removed if found,
     *  {@code null} if null String input
     */
    def static String removeStart(final String str, final String remove) {
        if (isEmpty(str) || isEmpty(remove)) {
            return str;
        }
        if (str.startsWith(remove)){
            return str.substring(remove.length());
        }
        return str;
    }

    /**
     * @description Removes {@code separator} from the end of
     * {@code str} if it's there, otherwise leave it alone.
     * @param str  the source String to search, may be null
     * @param remove  the String to search for and remove, may be null
     * @return String without trailing separator, {@code null} if null String input
     *  {@code null} if null String input
     */
    def static String removeEnd(final String str, final String remove) {
        if (isEmpty(str) || isEmpty(remove)) {
            return str;
        }
        if (str.endsWith(remove)) {
            return str.substring(0, str.length() - remove.length());
        }
        return str;
    }
}