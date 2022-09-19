extends RefCounted
class_name TNTokenizer

const KEYWORDS := [
	"fn", "class", "if", "unless", "null",
	"and", "or", "not",
	
	"enum", "flags", "var", "const",
	
	"int", "string", "list"
]

const OPERATORS := {
	"ASSIGN_TYPED": ":=",
	"ASSIGN": "=",
	"PLUS": "\\+",
	"MINUS": "-",
	"PRODUCT": "\\*",
	"DIVISION": "/",
	"FLOOR_DIVISION": "//",
	"PERCENT": "%",
	"OBJECT_CALL": "\\(\\)",
	"MEMBER_ACCESS": "\\."
}

const OPERATORS_CLEAN := {
	"ASSIGN_TYPED": ":=",
	"ASSIGN": "=",
	"PLUS": "+",
	"MINUS": "-",
	"PRODUCT": "*",
	"DIVISION": "/",
	"FLOOR_DIVISION": "//",
	"PERCENT": "%",
	"OBJECT_CALL": "()",
	"MEMBER_ACCESS": "."
}

const BOOLEANS := [
	'yes', 'true', 'on', 'no', 'false', 'off'
]

const BOOLEANS_TRUTH := [
	'yes', 'true', 'on'
]

class Token:
	var token : StringName
	var content = null
	
	static func create(_t : StringName, _c = null) -> Token:
		var tt = Token.new()
		tt.token = _t
		tt.content = _c
		return tt
	
	func _to_string():
		if content != null:
			return "[%s %s]" % [token, content]
		return "[%s]" % token

static func tokenize(raw: String) :
	# Current character offset
	var i := 0
	
	# Code length
	var size = len(raw)
	
	# Set of tokens to be returned
	var tokens := []
	
	# Current indentation level
	var current_indent := 0
	var indent_stack := []
	
	# Read the entire code
	while i < size:
		# The chunk of code is the entire code from
		# the current character to the end.
		var chunk = raw.substr(i)
		
		# The term we'll be constantly matching.
		# Basically, we match the term against a regex,
		# to find the first match that matches a certain
		# structure.
		# If it fits, we add a token and go to the next
		# iteration.
		var term
		
		# Note that the order matters.
		
		# IDENTIFIER
		term = qmatch(chunk, "\\A([a-zA-Z_](\\w|\\d)*)")
		if term:
			# If is a registered keyword,
			# add that keyword as a token.
			if KEYWORDS.has(term[1]):
				tokens.push_back(Token.create(
					StringName(term[1].to_upper()),
					null
				))
			# If it's a boolean constant, add its truth value
			# as a token.
			elif BOOLEANS.has(term[1]):
				tokens.push_back(Token.create(
					&"LITERAL_BOOLEAN",
					BOOLEANS_TRUTH.has(term[1])
				))
			# Otherwise, it might be a variable.
			else:
				tokens.push_back(Token.create(
					&"IDENTIFIER",
					term[1]
				))
			# Make sure to skip that amount of characters.
			i += len(term[1])
			continue
		
		# HEX INTEGER LITERAL
		term = qmatch(chunk, "\\A(0x([0-9a-fA-F])+)")
		if term:
			tokens.push_back(Token.create(
				&"LITERAL_INTEGER",
				term[1].hex_to_int()
				))
			# Make sure to skip that amount of characters.
			i += len(term[1])
			continue
		
		# DECIMAL INTEGER LITERAL
		term = qmatch(chunk, "\\A([0-9]+)")
		if term:
			tokens.push_back(Token.create(
				&"LITERAL_INTEGER",
				term[1].to_int()
				))
			# Make sure to skip that amount of characters.
			i += len(term[1])
			continue
		
		# STRING LITERAL
		term = qmatch(chunk, "\\A(\"(.*?)\"|'(.*?)')")
		if term:
			tokens.push_back(Token.create(
				&"LITERAL_STRING",
				term[2] + term[3]
				))
			# Make sure to skip that amount of characters.
			i += len(term[1])
			continue
		
		# STATEMENT_END
		term = qmatch(chunk, "\\A;")
		if term:
			tokens.push_back(Token.create(
				&"BACKSLASH",
				))
			# Make sure to skip that amount of characters.
			i += 1
			continue
		
		# COMMA
		term = qmatch(chunk, "\\A,")
		if term:
			tokens.push_back(Token.create(
				&"COMMA",
				))
			# Make sure to skip that amount of characters.
			i += 1
			continue
		
		# PARENTHESIS
		term = qmatch(chunk, "\\A\\(")
		if term:
			tokens.push_back(Token.create(
				&"PARENTHESIS_OPEN",
				))
			# Make sure to skip that amount of characters.
			i += len(term[0])
			continue
		term = qmatch(chunk, "\\A\\)")
		if term:
			tokens.push_back(Token.create(
				&"PARENTHESIS_CLOSE",
				))
			# Make sure to skip that amount of characters.
			i += len(term[0])
			continue
		
		# LIST
		term = qmatch(chunk, "\\A\\[")
		if term:
			tokens.push_back(Token.create(
				&"LIST_OPEN",
				))
			# Make sure to skip that amount of characters.
			i += len(term[0])
			continue
		term = qmatch(chunk, "\\A\\]")
		if term:
			tokens.push_back(Token.create(
				&"LIST_CLOSE",
				))
			# Make sure to skip that amount of characters.
			i += len(term[0])
			continue
		
		# OBJECT
		term = qmatch(chunk, "\\A{")
		if term:
			tokens.push_back(Token.create(
				&"OBJ_OPEN",
				))
			# Make sure to skip that amount of characters.
			i += len(term[0])
			continue
		term = qmatch(chunk, "\\A}")
		if term:
			tokens.push_back(Token.create(
				&"OBJ_CLOSE",
				))
			# Make sure to skip that amount of characters.
			i += len(term[0])
			continue
		
		# OPERATORS
		var ops = OPERATORS.values()
		var op_regex = str(ops.pop_front())
		for op in ops:
			op_regex += "|" + op
		
		term = qmatch(chunk, "\\A(" + op_regex + ")")
		if term:
			var op_name = OPERATORS_CLEAN.find_key(term[1])
			tokens.push_back(Token.create(
				StringName("OP_" + op_name),
				))
			# Make sure to skip that amount of characters.
			i += len(term[0])
			continue
		
		## Identation Magic (???) ##
		
		# ESCAPE_NEWLINE
		term = qmatch(chunk, "\\A(\n(\\t*))")
		if term:
			# Make sure to skip that amount of characters.
			i += len(term[1])
			continue
		
		# Match newlines, and indentation open/close.
		term = qmatch(chunk, "(?m)\\A\n(\\t*)")
		if term:
			var i_size = len(term[1])
			
			# If the level is bigger than the current one,
			# add it to the stack and as a token.
			if i_size > current_indent:
				current_indent = i_size
				indent_stack.push_back(current_indent)
				tokens.push_back(Token.create(
					&"INDENT_OPEN"
					))
			# If a lower level...
			elif i_size < current_indent:
				# While the current indent level is bigger
				# than the target indent size...
				while i_size < current_indent:
					# Lower the current indentation level
					# backwards thru the indent stack...
					indent_stack.pop_back()
					if indent_stack.size() > 0:
						current_indent = indent_stack[-1]
					# Won't go less than 0.
					else:
						current_indent = 0
					tokens.push_back(Token.create(
						&"INDENT_CLOSE"
						))
				tokens.push_back(Token.create(
					&"NEWLINE"
					))
			# If the same level of indentation,
			# just register a newline.
			else:
				tokens.push_back(Token.create(
				&"NEWLINE"
				))
			i += len(term[0])
			continue
		
		# WHITESPACE
		term = qmatch(chunk, "\\A ")
		if term:
			# Basically just ignore it.
			i += 1
			continue
		
		# If nothing matches, just add the current character.
		tokens.push_back(Token.create(
			&"CHARACTER",
			chunk[0]
			))
		i += 1
		
	
	# Close all open indents
	for _i in indent_stack:
		tokens.push_back(Token.create(
			&"INDENT_CLOSE"
			))
	
	return tokens

static func ERROR(error:String):
	print("(!) " + error)

static func qmatch(sub: String, regex: String):
	var r = RegEx.new()
	if r.compile(regex) != OK : return null
	var m = r.search(sub)
	if not m: return m
	return m.strings
