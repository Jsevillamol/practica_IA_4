package turnos;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Turnos {
	
	private static int nExamenes;
	private static int nTurnos;
	private static int nProfesores;
	
	private static List<String> profesorado = new ArrayList<>();
	private static Map<String, List<Integer>> restricciones = new HashMap<>();
	private static Map<String, List<Integer>> preferencias = new HashMap<>();
	
	//For debuging
	private static final Logger logger = Logger.getLogger("Log");

	public static void main(String[] args) {
		if (args.length==0) {
			//TODO pedir un path
			System.err.println("Especifique un fichero con los datos:");
			Scanner in = new Scanner(System.in);
			args = new String[]{in.nextLine()};
		}
		
		try {
			Scanner sc = new Scanner(new File(args[0]));
			readData(sc); //Guarda los datos en las variable globales.
			findSolution();
		} catch (FileNotFoundException e) {
			System.err.println("Fichero mal especificado.");
			System.exit(2);
		}
	}

	private static void findSolution() {
		//TODO Encontrar una asignación
	}
	
	/**
	 * Lee los datos del Scanner y los guarda en las variables globales.
	 * 
	 * @param sc Scanner de donde se leen los datos
	 */
	private static void readData(Scanner sc) {
		logger.setLevel(Level.ALL);
		nTurnos = sc.nextInt();
		sc.nextLine();//Hay que ignorar el salto de linea
		logger.severe("Numero "+nTurnos);
		profesorado = Arrays.asList((sc.nextLine()).split(", "));
		logger.severe(profesorado.toString());
		nProfesores = profesorado.size();

		//Restricciones
		readProfessorsInfo(sc, restricciones);

		//Preferencias
		logger.severe("Preferencias");
		readProfessorsInfo(sc, preferencias);
	}

	private static void readProfessorsInfo(Scanner sc, Map<String, List<Integer>> info) {
		String[] datosProfesor;
		for (int i = 0; i<nProfesores; i++) {
			datosProfesor = (sc.nextLine()).split(": ");
			if (datosProfesor.length==2) {
				List<Integer> lista = new ArrayList<>();
				for(String str2 : datosProfesor[1].trim().split(","))
					lista.add(Integer.parseInt(str2));
				info.put(datosProfesor[0], lista);
				logger.severe(datosProfesor[0] +" "+ lista.toString());
			}
		}
	}
}












