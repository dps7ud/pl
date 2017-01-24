let max_list = fun (lst: list int) : int => {
    List.fold_left max (List.hd lst) lst;
};
