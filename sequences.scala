package Chem

object Sequences{}	

class Sequences private (values: List[String], str : String) {
	var seq1 = values(0)
	var seq2 = values(1)	
	def read_seq(lines : List[String], sequence : String) : String ={
		(lines) match{
			case (head :: tail) if (head.trim.isEmpty()) =>  sequence 
			case (head :: tail) => read_seq(tail,sequence + head.trim.replace(" ",""))
			case (Nil) => sequence
		}
	}		
	def find_seq(lines : List[String], seq_mark : String, result : List[String]) : List[String] ={
		(lines,seq_mark) match{
			case (head :: tail,seq_mark) if (head.startsWith(seq_mark)) => find_seq(tail,seq_mark,result :+ read_seq(tail,""))
			case (head :: tail,seq_mark) => find_seq(tail,seq_mark,result)
			case (Nil,seq_mark) => result
		}
	}	
	def this(lines : List[String]) = this(find_seq(lines,">",List()),"done")
}