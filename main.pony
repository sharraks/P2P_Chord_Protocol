use "package:./RandomNumberGenerator"
use "math"
use "collections"
use "time"


actor Node
    let env: Env
    let fingerTable: Array[USize] = []
    let ftEnteries: USize
    let numNodes: USize
    let id: USize
    var successor: USize = 0
    var predecessor: USize = 0
    
    new create(env': Env,id': USize, numNodes': USize, m': USize) =>
        env = env'
        numNodes = numNodes'
        ftEnteries = m'
        id = id'
        
        //setting successor and predecessor for a node
        if(id == 0) then
            successor = 1
            predecessor = numNodes-1
        elseif (id > 0) and (id < (numNodes-1)) then
            successor = id + 1
            predecessor = id - 1
        else
            successor = 0
            predecessor = numNodes-2
        end
        
        let c: F64 = 2.0

        //creating finger table with m enteries 
        for i in Range(0,ftEnteries) do
            fingerTable.push((id + ((c.pow(i.f64()).usize()) % numNodes)))
        end


    be lookUp(key:USize, supe: ChordSupervisor) =>
        //if node ie equal to key then only one hop is required
        if (key == id)  then
            supe.receive(1)
        end

        //if key is present in fingertable or between nodes of finger table then two hops are required
        for i in Range(1,ftEnteries-1) do
            try
                if ((key == fingerTable(i)?) or ((key > fingerTable(i)?) and (key < fingerTable(i+1)?))) then
                    supe.receive(2)
                end
            end
        end

        //if key is the last successor in finger table than 2 hops are required
        //if key is greater than the last successor in finger table then finger table of last successor needs to be accessed with 2 hops from current node.
        try 
            let idx: USize = fingerTable(ftEnteries-1)?
            if (key == idx) then
                supe.receive(2)
            elseif ((key > idx) or (key < id)) then
                supe.receive(2)
                supe.forwardLookUp(idx, key)
            end
        end


actor ChordSupervisor
    let nodes: Array[Node] = []
    let numNodes: USize
    let numRequests: USize
    let enteries: USize
    var totalHops: I64 = 0
    var totalLookups: I64 = 0
    let env: Env
    var last: I64 = -10000 //variable to check if totalhops have converged

    new create(env': Env, numNodes': USize, numRequests': USize, m:F64) =>
        env = env'
        numNodes = numNodes'
        numRequests = numRequests'
        enteries = m.usize()

    be routing() =>
        env.out.print("Adding nodes to Ring")

        //add node to chord
        for i in Range(0,numNodes) do
            nodes.push(Node(env,i,numNodes,enteries))
        end
    
        env.out.print("Nodes Added...Starting communication")

        //hit all nodes to lookup for a random key
        for j in Range(0,numRequests) do
            for k in Range(0,numNodes) do
                //generate random key using randomize class - self defined
                let key:USize = Randomize.randn(0,numNodes.i64())
                try
                    nodes(k)?.lookUp(key, this)
                    totalLookups = totalLookups + 1
                end
            end    
        end

        checkChange()

    be checkChange() =>
        //behavior to check if the convergence has been achieved and there are no further changes in total hops value
        if(totalHops == last) then
            var retries: USize = 0
            //arbitrary value for retries can be increased if this is too low to render
            while retries < 100 do
                if totalHops == last then
                    retries = retries + 1
                end
            end
        else
            last = totalHops
        end
        //if no change call the stats to display info
        stats()

    be receive(hops: I64) =>
        //update the val for total hops taken till a given instant
        totalHops = totalHops + hops
    
    be forwardLookUp(idx:USize, key: USize) =>
        //check finger table of last successor of previous node for key
        try
            nodes(idx)?.lookUp(key, this)
        end

    be stats() =>
        //output about chord performance
        env.out.print("Total hops taken: "+totalHops.string()) 
        env.out.print("Total lookups: "+totalLookups.string())
        env.out.print("Average hops taken: "+(totalHops.f64()/totalLookups.f64()).string())

actor Main 
    var numNodes: USize = 0
    var numRequests: USize = 0
    let env: Env
    
    new create(env': Env) => 
        env = env'

        try  
            //take input from cli
            numNodes = env.args(1)?.usize()?
            numRequests = env.args(2)?.usize()?
            
            //default values in case a wrong input is provided
            if((numNodes <= 0) or (numRequests <=0)) then
                env.out.print("Wrong Input Provided")
                env.out.print("Taking default params for these: numNodes=256, numRequests=3")
                numNodes = 256
                numRequests = 3
            end
            
            let c: F64 = 2.0
            let m: F64 = makeRingPerfect(numNodes)
            numNodes = c.pow(m).usize()
                    
            env.out.print("Initaiting the chord ring and adjusted with "+numNodes.string()+" nodes to make (2^m)")
            
            let supervisor = ChordSupervisor(env,numNodes, numRequests, m)
            supervisor.routing()
            
        else
            options()
            return
        end

    fun options() =>
        //function to guide user about input
        env.out.print(
            """

            Run the program in shell while passing arguments. Ex: ./Rakshit_Sharma_P2P 32[numNodes] 3[numRequests] 

            OPTIONS
            numNodes: Number of nodes in the ring
            numRequets: Number of requests made by each node before application terminates
            """
        )
    
    fun makeRingPerfect(n: USize) : F64 =>
        //check of numNodes provided by user are power of 2.
        if n == 1 then
            return 1.0 
        elseif (((n) and (n - 1)) == 0) then
            return n.f64().log2()
        end
        //else return the nearest power of 2
        n.f64().log2().ceil()