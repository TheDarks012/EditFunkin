extends Node
class_name Sort

static func alfabetic(a:String, b:String) -> bool:
	var abc = null
	var letterNumber = 0
	while abc == null:
			var binaryA = a.to_ascii_buffer()
			var binaryB = b.to_ascii_buffer()
			
			if binaryA.size()-1 <= letterNumber:
				abc = true
			if binaryB.size()-1 <= letterNumber:
				abc = false
			
			var letterABinary = binaryA[letterNumber]
			var letterBBinary = binaryB[letterNumber]
			if letterABinary != letterBBinary:
				abc = letterABinary < letterBBinary
			
			
			letterNumber += 1
	return abc
