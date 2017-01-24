let c_to_f = fun (temp:float) : float => {
    temp *. 1.2 +. 32.0
};

let split_tip = fun (price:float) (n:int) : option float => {
    /* Split total 'price' of check 'n' ways 
       return price with %20 tip split n ways.
       if n < 1 or price < 0:
           return None
    */
    if (n < 1 || price < 0.0) {None} else {Some (price *. 1.2 /. (float n))}
};

let triangle_area = fun (s1:float) (s2:float) (s3:float) : option float => {
    /* If s1,s2, and s3 form a valid triangle, 
       return the area of this trianlge
       otherwise, return None
    */
    let lst = [s1, s2, s3];
    let m = List.fold_left max (List.hd lst) lst;
    let lst = List.filter (fun(a) => {a < m}) lst;
    if (List.fold_left (+.) 0.0 lst > m) {
        None
    } else {
        let s = s1 +. s2 +. s3;
        Some (sqrt( s *. (s -. s1) *. (s -. s2) *. (s -. s3)));
    }
};

let rec repeat = fun (f: 'a => 'a) (arg: 'a) (n: int) => {
    /* Given unary function f, argument arg and int n,
       return f^n(arg)
    */
    if (n == 0){
        arg;
    } else {
        repeat f (f(arg)) n-1;
    }
};

let list_length = fun (l: list 'a) : int => {
    /* Return the number of items in list l */
    let rec recursive_len = fun (lst:list 'a) (acc:int) => {
        switch lst {
            | [] => 0
            | _ => recursive_len (List.tl lst) (acc + 1)
        };
    };

    recursive_len l 0;
};
