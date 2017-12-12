package turnos;

import aima.core.search.framework.problem.GoalTest;
import aima.core.search.local.FitnessFunction;
import aima.core.search.local.GeneticAlgorithm;
import aima.core.search.local.Individual;
import modificacionGenetico.CustomGeneticAlgorithm;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Turnos {

	public static final boolean customGeneticAlgorithm = true;
	/**Repite el algoritmo RERUNS veces o hasta que encuentra una solucion*/
	private static final int RERUNS = 10;

	private static int nExamenes;
	private static int nTurnos = 16;
	private static int nProfesores;
	
	private static List<String> profesorado = new ArrayList<>();
	private static Map<String, List<Integer>> restricciones = new HashMap<>();
	private static Map<String, List<Integer>> preferencias = new HashMap<>();
	
	//For debuging
	private static final Logger logger = Logger.getLogger("Log");

	public static void main(String[] args) {
		if (args==null || args.length==0) {
			System.out.println("Especifique un fichero con los datos:");
			Scanner in = new Scanner(System.in);
			args = new String[]{in.nextLine()};
		}
		
		try {
			Scanner sc = new Scanner(new File(args[0]));
			readData(sc); //Guarda los datos en las variable globales.
			System.out.println("Data read");
			findSolution();
			//if (true) main(args);//Para repetir infinitamente
		} catch (FileNotFoundException e) {
			System.err.println("Fichero mal especificado.");
			System.exit(1);
		}
	}

	private static void findSolution() {
		FitnessFunction<String> fitnessFunction = new TurnosFitnessFunction(profesorado, restricciones, preferencias, nTurnos);
		GoalTest goalTest = new TurnosGoalTest((TurnosFitnessFunction) fitnessFunction, restricciones, nExamenes);
		GeneticAlgorithm<String> ga;
		if (customGeneticAlgorithm)
			ga = new CustomGeneticAlgorithm(nTurnos, profesorado, 0.15);
		else
			ga = new GeneticAlgorithm<>(nTurnos, profesorado, 0.15);
		Set<Individual<String>> population;
		Individual<String> bestIndividual;
		int attempt = 0;

		// Stats
        double minFitness = Double.MAX_VALUE;
        double totalFitness = 0;
        double maxFitness = Double.MIN_VALUE;

		int minIter = Integer.MAX_VALUE;
		int totalIter = 0;
		int maxIter = Integer.MIN_VALUE;

        double minTime = Double.MAX_VALUE;
        double totalTime = 0;
        double maxTime = Double.MIN_VALUE;



        boolean goalReached = false;

		do {
			// Generate an initial population
			population = new HashSet<>();
			for (int i = 0; i < TurnosUtil.POBLACION_INICIAL; i++)
				population.add(TurnosUtil.generateRandomIndividual(profesorado, nExamenes, nTurnos));

			bestIndividual = ga.geneticAlgorithm(population, fitnessFunction, goalTest, TurnosUtil.MAX_TIME);
			//System.out.println("Attempt: " + attempt);
			//TurnosUtil.showInfo(ga, bestIndividual, fitnessFunction, goalTest, nTurnos, nExamenes, nProfesores);

			// running stats
            double fitness = fitnessFunction.apply(bestIndividual);
            minFitness = Math.min(minFitness, fitness);
            totalFitness += fitness;
            maxFitness = Math.max(maxFitness, fitness);

            double time = ga.getTimeInMilliseconds();
            minTime = Math.min(minTime, time);
            totalTime += time;
            maxTime = Math.max(maxTime, time);

			int iter = ga.getIterations();
			minIter = Math.min(minIter, iter);
			totalIter += iter;
			maxIter = Math.max(maxIter, iter);

            goalReached |= goalTest.isGoalState(bestIndividual);

		} while (++attempt< RERUNS);

		// Print running stats
        double meanFitness = totalFitness / RERUNS;
        double meanIter = totalIter / RERUNS;
        double meanTime = totalTime / RERUNS;

        System.out.println("Results after" + RERUNS + "attempts");

        System.out.println("min fitness = " + minFitness);
		System.out.println("mean fitness = " + meanFitness);
		System.out.println("max fitness = " + maxFitness);

		System.out.println("min iterations = " + minIter);
		System.out.println("mean iterations = " + meanIter);
		System.out.println("max iterations = " + maxIter);

		System.out.println("min time = " + minTime);
		System.out.println("mean time = " + meanTime);
		System.out.println("max time = " + maxTime);

    }
	
	/**
	 * Lee los datos del Scanner y los guarda en las variables globales.
	 * 
	 * @param sc Scanner de donde se leen los datos
	 */
	private static void readData(Scanner sc) {
		logger.setLevel(Level.OFF);
		nExamenes = sc.nextInt();
		sc.nextLine();//Hay que ignorar el salto de linea
		logger.severe("Numero "+nExamenes);
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












