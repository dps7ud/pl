let c_to_f = fun (temp:float) : float => {
    temp *. 1.8 +. 32.0
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
    let a = s2 +. s1;
    let b = s3 +. s2;
    let c = s1 +. s3;
    if( a <= 0.0 || b <= 0.0 || c <= 0.0 || s1 <= 0.0 || s2 <= 0.0 || s3 <= 0.0){
        None
    } else {
        let s = (s1 +. s2 +. s3) /. 2.0;
        let a = s -. s1;
        let b = s -. s2;
        let c = s -. s3;
        let total = sqrt (s *. a *. b *. c);
        if(total <= 0.0){
            None
        } else {
            Some (total);
        }
    }
};

let rec repeat = fun (f: 'a => 'a) (arg: 'a) (n: int) => {
    /* Given unary function f, argument arg and int n,
       return f^n(arg)
    */
    if (n == 0){
        arg
    } else {
        repeat (f) (f(arg)) (n-1);
    }
};

let list_length = fun (l: list 'a) : int => {
    /* Return the number of items in list l */
    let rec recursive_len = fun (lst:list 'a) (acc:int) => {
        let ans = switch lst {
            | [] => acc
            | _ => recursive_len (List.tl lst) (acc + 1)
        };
        ans
    };
    recursive_len l 0;
};
