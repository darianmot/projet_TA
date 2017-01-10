open Sequencement;;
open Airport;;

let file = "data/lfpg_flights.txt";;

(*-----------------*)
(* Programs options *)
let line_to_read = ref (-1)
let vitesse_plot = ref 1.0
let debut_plot = ref 5000
let sequencement = ref "opt"
  
let speclist = [
  ("-n", Arg.Set_int line_to_read, "Restriction du nombre de ligne du fichier à charger");
  ("-v", Arg.Set_float vitesse_plot, "Vitesse relative des plots de l'animation");
  ("-d", Arg.Set_int debut_plot, "Temps de debut de la simulation (en secondes)");
  ("-s", Arg.Set_string sequencement, "Type de sequencement utilisé (\"opt\" pour le sequencement optimal, \"fcfs\" pour le sequencement fcfs, \"\" pour aucun sequencement)")
]
  
let anonymous_fun= fun s -> failwith (Printf.sprintf "There should be no anonymous arguments: %s" s)
  
let usage_msg= "Options available";;


(*---------------------*)
(* Programme principal *)
let main () =

  (*Parse de la ligne de commande *)
  Arg.parse speclist anonymous_fun usage_msg;
  
  (* Chargement du traffic et de l'aeroport *)
  let load = Traffic.read ~n:(!line_to_read) file in
  let lfpg = read_airport "data/lfpg_map.txt" in

  (* Sequencement des avions *)
  let sequence_fun = match !sequencement with
    |"opt" -> seq_final_opti
    |"fcfs" -> seq_final_fcfs
    |_ -> fun x -> (x,0) in
  let time_debut = Sys.time() in
  let (load_sequence, retard_seq) = sequence_fun load in
  let time_fin = Sys.time() in
  Printf.printf "Temps sequencement : %f\n" (time_fin -. time_debut);
  flush_all ();
  
  (* Resolution des conflits *)
  let t1 = Sys.time () in
  let (load_resolved, retard_solve) = Solve.resolution load_sequence lfpg in
  let t2 = Sys.time () in
  begin
    Printf.printf "Retard total : %d\n" (retard_seq + retard_solve);
    Printf.printf "Temps : %f\n" (t2 -. t1);
    flush_all ();
    Plot.start !debut_plot load_resolved lfpg !vitesse_plot;
    end;;

main ();;
