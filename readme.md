

**Problem Statement**
In this project we have to design the Chord Protocol functionality as discussed in the section 4 of this paper: https://pdos.csail.mit.edu/papers/ton:chord/paper-ton.pdf

**To Run**
Download the files and from the root directly launch cmd, and run 'ponyc'. It will generate an object file.

Input: The input provided (as command line to P2P_Chord_Protocol) will be of the form:

./P2P_Chord_Protocol numNodes  numRequests

Where numNodesis the number of peers to be created in the peer-to-peer system and numRequests is the number of requests each peer has to make.  When all peers performed that many requests, the program can exit.  Each peer should send a request/second.

Output: Print the average number of hops (node connections) that have to be traversed to deliver a message.

**Code Logic**
In my submitted code there are three actors - Main, ChordSupervisor and Node. The main actor is to take input from user from cli and check for wrong inputs. Main actor also resizes the chord according to the nearest power of 2. The main actor invokes the ChordSupervisor actor which builds the network and start the transmission of messages based on random keys. 
For generating random keys I am using the RandomNumberGenerator package that I have built using the builtin Random.pony package to get more random values, as builtin function only provides 0 as output.
The ChordSupervisor keeps tracks of hops submitted by individual nodes via messagesand increment the value. There is a checkChange behavior to check continuously if the value of total hops have not changed for sometime. That means our communication process has completed and we can show the average hops taken by chord.
The node actor has lookup function to find key from its successors. Implementation is based on the paper mentioned above, using the finger table approach.
