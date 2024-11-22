use "random"
use "time"

class Randomize
    //change random factor to increase randomness between two distinct time bound outputs
    var randomFactor : I64 = 1
    
    fun ref randn(min:I64, max: I64) : USize =>

        let a = Time.now()
        let b = Time.now()
        //arbitrary logic to create random number with current local time difference in milliseconds
        var c: I64 = ((b._2 - a._2) * (Rand.next().i64())) * randomFactor

        c = min + (c % max)

        c.usize()

