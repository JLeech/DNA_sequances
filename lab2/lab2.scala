//это класс-компаньон к классу который содержит последовательности;
object Sequences{


	def read_seq(lines : List[String], sequence : String) : String ={
		(lines) match{
			case (head :: tail) if (head.trim.isEmpty()) =>  sequence 
			case (head :: tail) => read_seq(tail,sequence + " " + head.trim)
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
}

//это класс который содержит последовательности
class Sequences private (values: List[String], str : String) {
	var seq1 = values(0).replace(" ","")
	var seq2 = values(1).replace(" ","")

	//вот так необычно тут вызываются конструкторы
	def this(lines : Array[String]) = this( Sequences.find_seq(lines.toList,">",List()),"done")
	//все методы в object (класс компаньон), потому что нельзя вызывать методы класса из конструктора
}


object Parameters{
	//вот тут происходит парсинг по гепам, вставкам, удалениям
	//обратите внимание, как всё сплетено. такой стиль меня и подкупил
	def parse(lines : List[String], limits : List[String]) : List[String] ={
		(lines,limits) match {
			case (head :: tail,limits) if (head.indexOf(";") > 0) => parse(tail,limits :+ head.take(head.indexOf(";")))
			case (head :: tail,limits) if (head.indexOf(";") == 0) => parse(tail,limits :+ Sequences.read_seq(tail, ""))
			case (Nil,limits) => limits.map(str => str.trim)
			case (head :: tail,limits) => parse(tail,limits)
		}
	}

	def del_n_str(str : String, num : Int) : String ={
		(str,num) match {
			case("",num) => ""
			case(str,num) => str.split(" ").filterNot(value => value.trim == "" ).drop(num).mkString(" ")
		}
	}

	def take_n_str(str : String, num : Int) : List[Int] ={
		(str,num) match {
			case("",num) => List()
			case(str,num) => str.split(" ").filterNot(value => value.trim == "" ).map(value => value.toInt).take(num).toList
		}
	}
}

class Parameters private (values: List[String],str : String) {
	var gap = values(0).toInt
	var del_ins = values(1).toInt
	var alphabet = values(2).split(" ").toList
	var matrix = form_matrix(values(3), Map[ String, Map[String,Int]](), 0 )

	def form_matrix(line : String, result : Map[ String, Map[String,Int] ], index : Int) : Map[ String, Map[String,Int] ] ={
		(line,result,index) match {
			case (line, result, index) if (line.trim.length > 0) => {
				//а вот так круто формируется матрица
				//такие заморочки специально, чтобы можно было по чарам вытаскивать значения
				//хотя это не особо помогло;
				form_matrix(Parameters.del_n_str(line,alphabet.length), result + (alphabet(index) -> (alphabet zip Parameters.take_n_str(line,alphabet.length)).toMap),index+1)
			}
			case ("",result,index) => result
		}
		
	}

	def this(lines : Array[String]) = this(Parameters.parse(lines.toList, List()), "" ) 
}


val seq_lines = scala.io.Source.fromFile("./input3.txt").mkString.split("\n")
val seqs = new Sequences(seq_lines)

println("seq1: "+seqs.seq1)
println("seq2: "+seqs.seq2)

var limits_lines = scala.io.Source.fromFile("./parameter2.txt").mkString.split("\n")
val limits = new Parameters(limits_lines)

println ("alphabet: "+limits.alphabet)
println ("matrix: "+limits.matrix)
