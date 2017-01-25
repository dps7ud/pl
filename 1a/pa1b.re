let salutations = fun (l: list string) : list string => {
    /* Given a list of strings, return a list of strings with greetings*/
}

let dot_product = fun (l1: list int) (l2: list int) : option int => {
    /* Given two integer lists return the dot product of the two lists
       or None if the lists differ in length 
    */
}

let count = fun (l: list 'a) (e: 'a) : int => {
    /* Given a list and an element, return the number of occurences
    of the element in the list.
    */
}

let pre_order = fun (t: int_tree) : list int => {
    /* Return a list of tree elements as they would be visited
    in a pre-order traversal
    */
}

let int_tree_map = fun (f: int => int) (t: int_tree) : int_tree => {
    /* Given a function and a tree, return a treee coresponding to 
    the given tree with the function applied to every node.
    */
}
