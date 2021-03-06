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
class Sequences private (values: List[String], str : String) {
	var seq1 = values(0).replace(" ","")
	var seq2 = values(1).replace(" ","")

	def this(lines : Array[String]) = this( Sequences.find_seq(lines.toList,">",List()),"done")
}

object Parameters{

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
				form_matrix(Parameters.del_n_str(line,alphabet.length), result + (alphabet(index) -> (alphabet zip Parameters.take_n_str(line,alphabet.length)).toMap),index+1)
			}
			case ("",result,index) => result
		}
		
	}



	def this(lines : Array[String]) = this(Parameters.parse(lines.toList, List()), "" ) 
}

/*
val seq_lines = scala.io.Source.fromFile("./input2.txt").mkString.split("\n")
val seqs = new Sequences(seq_lines)

var limits_lines = scala.io.Source.fromFile("./parameter1.txt").mkString.split("\n")
val limits = new Parameters(limits_lines)

def fill_gap(matrix())

def fill_matrix( matrix : List[List[Int]], sequences : Sequences ,raw : Int, column : Int) : List[Int][Int] ={
	(matrix,sequences,raw,column) match {
		case (matrix,sequences,0,0) => fill_matrix(fill_gap(matrix,sequences),sequences,1,1)
	}
}*/

var aaa =  Map[ String, Map[String, Int]]()
var zzz =  Map[ String, Int]()
zzz = zzz + ("aaa" -> 10)
aaa = aaa + ("zzz"-> zzz)
aaa = aaa + (aaa("zzz") + ("bbb" -> 10))
println(aaa("zzz")("bbb"))


/*
println(limits.gap)
println(limits.del_ins)
println(limits.alphabet)
println(limits.matrix)


var aaa = Map[ String, Map[String,String] ]()
var zzz = Map[String,String]()

zzz = zzz + ("aa" -> "bb")
aaa = aaa + ("zz" -> zzz)
*/
//println(zzz("aa"))
//println(aaa("zz")("aa"))



//val limits = 
/*


var Ha:Map[String,String] = Map()

Ha +=("a" -> "b")
println(Ha("a"))

for (line <- scala.io.Source.fromFile("./input1.txt").getLines()){
	print("["+line+"]")
	(line) match {
		case () => out
	}
}

case (out,List()) => out

var lines = scala.io.Source.fromFile("./input1.txt").getLines()

lines.foreach(println)

def seq(s : String) = s.trim.endsWith("seq1")

//println(lines.toList.find(s => seq(s)))

val leters = List("AA","BB","CC")

println(leters.find(c => seq(c)))*/