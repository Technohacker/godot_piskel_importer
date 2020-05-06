extends Object

const BASE64_DICTIONARY = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

# Takes in a binary value (int) and returns the decimal value (int)
static func bin2dec(var binary_value):
	var decimal_value = 0
	var count = 0
	var temp
	while(binary_value != 0):
		temp = binary_value % 10
		binary_value /= 10
		decimal_value += temp * pow(2, count)
		count += 1
	return decimal_value

# Takes in a decimal value (int) and returns the binary value (string)
static func dec2bin(var decimal_value):
	var binary_string = ""
	var temp 
	var count = 7 # Checking up to 8 bits 
	while(count >= 0):
		temp = decimal_value >> count 
		if(temp & 1):
			binary_string = binary_string + "1"
		else:
			binary_string = binary_string + "0"
		count -= 1
	return binary_string

static func decode(input: String):
	var binstr = "";

	for ch in input:
		var i = BASE64_DICTIONARY.find(ch)
		var bin = (dec2bin(i) as String)

		binstr += bin.substr(2)

	var count = 0
	var buf = PoolByteArray([])

	while (count < binstr.length() / 8):
		var byte = int(bin2dec(int((binstr as String).substr(count * 8, 8))))
		buf.append(byte)
		count += 1

	return buf
