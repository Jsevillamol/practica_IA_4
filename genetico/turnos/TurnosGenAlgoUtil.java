package genetico.turnos;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Arrays;

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
	public static final int nExamenes = 8;
	public static final int nTurnos = 16;

	// Lista de profesores, mas un simbolo especial al final para representar el turno vacío
	public static final List<String> profesorado  = Arrays.asList("ANA", "BONIATO", "CARLA", "DOMINGO", "ELISA", "FEDERICO", "GERTRUDIS", "VACIO");

  	public static final int nProfesores = profesorado.size();
  	public static final Random RANDOM = new Random();

  	public static final Map<String, List<Integer>> restricciones = new HashMap<>();
  	static
  	{
  	  	restricciones.put("ANA", Arrays.asList(1, 2, 3));
  	}

  	public static final Map<String, List<Integer>> preferencias = new HashMap<>();
  	static
  	{

  		preferencias.put("ANA", Arrays.asList(1,2,3));
  	}

	/****************************
	* Genetic Algorithm Functions
	*****************************/

	public static FitnessFunction<String> getFitnessFunction() {
		return new TurnosFitnessFunction();
	}
	
	public static GoalTest getGoalTest() {
		return new TurnosGenAlgoGoalTest();
	}
	

	public static Individual<String> generateRandomIndividual() {
		List<String> individualRepresentation = new ArrayList<String>();

		// Inicializamos la representacion con todo turnos vacios
		for (int i = 0; i < nTurnos; i++) {
			individualRepresentation.add("VACIO");
		}
		
		// Seleccionamos aleatoriamente nExamenes turnos y los asignamos a profesores aleatorios
		for (int i : getRandomSelection(nExamenes, nTurnos)){
			int randomIndex = RANDOM.nextInt(nProfesores);
			individualRepresentation.set(i, profesorado.get(randomIndex));
		}

		Individual<String> individual = new Individual<String>(individualRepresentation);
		return individual;
	}

	public static Collection<String> getFiniteAlphabet() {
		return profesorado;
	}
	
	public static class TurnosFitnessFunction implements FitnessFunction<String> {

		static private boolean preferenciasOrdenadas = false; // si es true, las preferencias con índices más bajos añaden más utilidad
		static private boolean turnosConsecutivos = false; // if true, la asignacion de turnos consecutivos da mas fitness

		public double apply(Individual<String> individual) {
			double fitness = 0;
			fitness = preferenciasFitness(individual) - restriccionesVioladas(individual) + equilibrioFitness(individual);
			if(turnosConsecutivos) fitness += turnosConsecutivosAsignados(individual);
			return fitness;
		}

		/*
		* Calcula cuantas preferencias satisface el individuo
		* Si preferenciasOrdenadas = true, entonces da más importancia a las preferencias con indices mas bajos de cada profesor
		*/
		private static int preferenciasFitness(Individual<String> individual){
			List<String> turnos = individual.getRepresentation();
			int nPreferencias = 0;
			for(int i = 0; i <= nTurnos; i++){
				String turno = turnos.get(i);
				if(turno != "VACIO" && preferencias.get(turno).contains(i)){
					if(! preferenciasOrdenadas) nPreferencias += 1;
					else {
						nPreferencias += nTurnos - preferencias.get(turno).indexOf(i);
					}
					
				}
			}
			return nPreferencias;
		}

		/*
		* Calcula cuantas restricciones viola el individuo
		*/
		public static int restriccionesVioladas(Individual<String> individual){
			List<String> turnos = individual.getRepresentation();
			int nRestricciones = 0;
			for(int i = 0; i <= nTurnos; i++){
				String turno = turnos.get(i);
				if(turno != "VACIO" && restricciones.get(turno).contains(i)){
					nRestricciones += 1;
				}
			}
			return nRestricciones;
		}

		/*
		* Calcula como de equilibrada es la distribucion de turnos sugerida por el individuo
		*/
		private static double equilibrioFitness(Individual<String> individual){
			// Realizamos una cuenta de cuantos turnos corresponden a cada profesor
			Map<String, Integer> turnosAsignados = new HashMap<>();
			for (String profe : profesorado){
				if(profe != "VACIO") turnosAsignados.put(profe, 0);
			}
			int turnosTotales = 0;
			for(String turno : individual.getRepresentation()){
				if (turno != "VACIO"){
					turnosAsignados.put(turno, turnosAsignados.get(turno) + 1);
					turnosTotales += 1;
				}
			}

			// Calculamos la diferencia absoluta de cada 
			double media = turnosTotales / nProfesores;
			double desviacion = 0;

			for(String profe : profesorado){
				if(profe != "VACIO") desviacion += Math.abs(turnosAsignados.get(profe) - media);
			}

			return desviacion;

		}

		/*
		 * Calcula los turnos consecutivos
		 */
		public static int turnosConsecutivosAsignados(Individual<String> individual){
			List<String> turnos = individual.getRepresentation();
			int nRachas = 0;
			String current = "VACIO";
			for(int i = 0; i <= nTurnos; i++){
				String turno = turnos.get(i);
				if(turno == current) nRachas += 1;
				else current = turno;
			}
			return nRachas;
		}

	}

	public static int contarTurnosNoVacios(Individual<String> individuo){
		int turnosTotales = 0;
			for(String turno : individuo.getRepresentation()){
				if (turno != "VACIO"){
					turnosTotales += 1;
				}
			}
		return turnosTotales;
	}

	public static class TurnosGenAlgoGoalTest implements GoalTest {

		public boolean isGoalState(Object state) {
			Individual<String> individuo = (Individual<String>) state;
			boolean restriccionesRespetadas = TurnosFitnessFunction.restriccionesVioladas(individuo) == 0;
			boolean examenesCubiertos = contarTurnosNoVacios(individuo) == nExamenes;
			return restriccionesRespetadas && examenesCubiertos;
		}
	}

	/*
	 * Loads the input data from a txt file
	 */
	public void loadInput(String path){

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
