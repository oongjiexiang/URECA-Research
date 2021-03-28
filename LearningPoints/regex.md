1. Syntax
```py
import re

txt = "The rain is in Spain"
x = re.search("^The.*Spain$", txt)  # returns Match object
x = re.findall("ai", txt)   # returns a list containing 'ai'
x = re.split("\s", txt, 1)     # split txt delimited by '\s', returns list; only at first occurence
x = re.sub("\s", "0", txt, 2)  # substitute  with 0; only the first 2 occurences
x = re.search(r"\bS\w+", txt); print(x.span())  # print (start of match, end of match)
print(x.string)     # prints txt
print(x.group())    # prints the matched strings, similar to re.findall()
```

2. Raw string
As can be seen from the above, raw string is passed when special sequences are passed

Special Sequence | Description
| :--- | :--- |
\A | beginning
\b | beginning or end
\B | not beginning or end
\d | digit
\D | not digit
\s[S] | whitespace [not]
\w[W] | word char [not]
\Z | end