package genetico.turnos;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Random;

import aima.core.search.framework.problem.GoalTest;
import aima.core.search.local.FitnessFunction;
import aima.core.search.local.Individual;
import aima.core.util.datastructure.XYLocation;

/**
 * A class whose purpose is to provide static utility methods for solving the
 * exam shift distribution problem with genetic algorithms. This includes fitness function,
 * goal test, random creation of individuals and convenience methods for
 * translating between between an NQueensBoard representation and the Integer list
 * representation used by the GeneticAlgorithm.
 * 
 * @author Jaime Sevilla
 * @author David Rubio
 * 
 */
public class TurnosGenAlgoUtil {

	/**************
    * Problem data
	*******************/
	private static final int nExamenes = 8;
	private static final int nTurnos = 16;

	// Lista de profesores, mas un simbolo especial para representar un turno vacío
	public static enum Profesor = {ANA, BONIATO, CARLA, DOMINGO, ELISA, FEDERICO, GERTRUDIS, VACIO}

	private static final List<Profesor> PROFESORADO = Collections.unmodifiableList(Arrays.asList(values()));
  	private static final int NPROFESORES = PROFESORADO.size()-1;
  	private static final Random RANDOM = new Random();

  	private static final restricciones;
  	private static final preferencias;

	/****************************
	* Genetic Algorithm Functions
	*****************************/

	public static FitnessFunction<Profesor> getFitnessFunction() {
		return new TurnosFitnessFunction();
	}
	
	public static GoalTest getGoalTest() {
		return new TurnosGenAlgoGoalTest();
	}
	

	public static Individual<Profesor> generateRandomIndividual(int boardSize) {
		List<Profesor> individualRepresentation = new ArrayList<Profesor>();

		// Inicializamos la representacion con todo turnos vacios
		for (int i = 0; i < nTurnos; i++) {
			individualRepresentation.add(Profesor.VACIO);
		}
		
		// Seleccionamos aleatoriamente nExamenes turnos y los asignamos a profesores aleatorios
		for (int i : getRandomSelection(nExamenes, nTurnos)){
			int randomIndex = RANDOM.nextInt(NPROFESORES);
			individualRepresentation.set(i, PROFESORADO.get(randomIndex));
		}

		Individual<Profesor> individual = new Individual<Profesor>(individualRepresentation);
		return individual;
	}

	public static Collection<Profesor> getFiniteAlphabet()) {
		return Profesor.values();
	}
	
	public static class TurnosFitnessFunction implements FitnessFunction<Profesor> {

		public double apply(Individual<Profesor> individual) {
			double fitness = 0;
			fitness = preferenciasFitness(individual) - restriccionesVioladas(individual) + equilibrioFitness(individual);
			return fitness;
		}

		/*
		* Calcula cuantas preferencias satisface el individuo
		*/
		private static int preferenciasFitness(Individual<Profesor> individual){

		}

		/*
		* Calcula cuantas restricciones viola el individuo
		*/
		public static int restriccionesVioladas(Individual<Profesor> individual){

		}

		/*
		* Calcula como de equilibrada es la distribucion de turnos sugerida por el individuo
		*/
		private static double equilibrioFitness(Individual<Profesor> individual){

		}

	}

	public static class TurnosGenAlgoGoalTest implements GoalTest {

		public boolean isGoalState(Object state) {
			return TurnosFitnessFunction.restriccionesVioladas((Individual<Profesor>) state)) == 0;
		}
	}

	public static NQueensBoard getBoardForIndividual(Individual<Integer> individual) {
		int boardSize = individual.length();
		NQueensBoard board = new NQueensBoard(boardSize);
		for (int i = 0; i < boardSize; i++) {
			int pos = individual.getRepresentation().get(i);
			board.addQueenAt(new XYLocation(i, pos));
		}

		return board;
	}


	/*
	* Devuelve una selección aleatoria uniforme de k números menores o iguales que n
	* Tomado de https://stackoverflow.com/a/29868630/4841832
	*/
	private static int[] getRandomSelection (int k, int n) {
    if (k > n) throw new IllegalArgumentException(
        "Cannot choose " + k + " elements out of " + n + "."
    );

    HashMap<Integer, Integer> hash = new HashMap<Integer, Integer>(2*k);
    int[] output = new int[k];

    for (int i = 0; i < k; i++) {
        int j = i + RANDOM.nextInt(n - i);
        output[i] = (hash.containsKey(j) ? hash.remove(j) : j);
        if (j > i) hash.put(j, (hash.containsKey(i) ? hash.remove(i) : i));
    }
    return output;
}
}
