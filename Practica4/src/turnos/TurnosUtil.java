package turnos;

import java.math.BigDecimal;
import java.util.*;

import aima.core.search.framework.problem.GoalTest;
import aima.core.search.local.FitnessFunction;
import aima.core.search.local.GeneticAlgorithm;
import aima.core.search.local.Individual;

public class TurnosUtil {

    public static final int POBLACION_INICIAL = 50;
    private static final Random RANDOM = new Random();

    /****************************
     * Genetic Algorithm Functions
     *****************************/


    public static Individual<String> generateRandomIndividual(List<String> profesorado, int nExamenes, int nTurnos) {
        List<String> individualRepresentation = new ArrayList<>();
        int nProfesores = profesorado.size();

        // Inicializamos la representacion con todo turnos vacios
        for (int i = 0; i < nTurnos; i++) {
            individualRepresentation.add("VACIO");
        }

        // Seleccionamos aleatoriamente nExamenes turnos y los asignamos a profesores aleatorios
        for (int i : getRandomSelection(nExamenes, nTurnos)) {
            int randomIndex = RANDOM.nextInt(nProfesores);
            individualRepresentation.set(i, profesorado.get(randomIndex));
        }

        Individual<String> individual = new Individual<>(individualRepresentation);
        return individual;
    }

    public static int contarTurnosNoVacios(Individual<String> individuo) {
        int turnosTotales = 0;
        for (String turno : individuo.getRepresentation()) {
            if (!(turno.equals("VACIO")))
                turnosTotales++;
        }
        return turnosTotales;
    }

    /*Devuelve una selección aleatoria uniforme de k números menores o iguales que n.
     * Tomado de https://stackoverflow.com/a/29868630/4841832 */
    private static int[] getRandomSelection(int k, int n) {
        if (k > n) throw new IllegalArgumentException(
                "Cannot choose " + k + " elements out of " + n + "."
        );

        HashMap<Integer, Integer> hash = new HashMap<Integer, Integer>(2 * k);
        int[] output = new int[k];

        for (int i = 0; i < k; i++) {
            int j = i + RANDOM.nextInt(n - i);
            output[i] = (hash.containsKey(j) ? hash.remove(j) : j);
            if (j > i) hash.put(j, (hash.containsKey(i) ? hash.remove(i) : i));
        }

        return output;
    }

    /**Shows the info of the result.*/
    public static void showInfo(GeneticAlgorithm<String> ga, Individual<String> bestIndividual,
                                FitnessFunction fitnessFunction, GoalTest goalTest,
                                int nTurnos, int nExamenes, int nProfesores){
        System.out.println("Max Time (1 second) Best Individual=\n" + bestIndividual);
        System.out.println("nTurnos      = " + nTurnos);
        System.out.println("nExamenes      = " + nExamenes);
        System.out.println("# Possible individuals = " + (
                new BigDecimal(nTurnos)).pow(nProfesores));
        System.out.println("Fitness         = " + fitnessFunction.apply(bestIndividual));
        System.out.println("Is Goal         = " + goalTest.isGoalState(bestIndividual));
        System.out.println("Population Size = " + ga.getPopulationSize());
        System.out.println("Iterations       = " + ga.getIterations());
        System.out.println("Took            = " + ga.getTimeInMilliseconds() + "ms.");
    }

    /**Calcula como de equilibrada es la distribucion de turnos sugerida por el individuo*/
    static double equilibrioFitness(Individual<String> individual, List<String> profesorado){
        // Realizamos una cuenta de cuantos turnos corresponden a cada profesor
        Map<String, Integer> turnosAsignados = new HashMap<>();
        for (String profe : profesorado){
            if(!(profe.equals("VACIO"))) turnosAsignados.put(profe, 0);
        }
        int turnosTotales = 0;
        for(String turno : individual.getRepresentation()){
            if (!(turno.equals("VACIO"))){
                turnosAsignados.put(turno, turnosAsignados.get(turno) + 1);
                turnosTotales += 1;
            }
        }

        // Calculamos la diferencia absoluta de cada
        double media = turnosTotales / profesorado.size();
        double desviacion = 0;

        for(String profe : profesorado){
            if(!(profe.equals("VACIO"))) desviacion += Math.abs(turnosAsignados.get(profe) - media);
        }

        return desviacion;

    }

    /**Calcula los turnos consecutivos*/
    public static int turnosConsecutivosAsignados(Individual<String> individual){
        List<String> turnos = individual.getRepresentation();
        int nRachas = 0;
        String current = "VACIO";
        for(String turno : turnos){
            if(turno == current) nRachas += 1;
            else current = turno;
        }
        return nRachas;
    }

    /**Calcula cuantas restricciones viola el individuo*/
    public static int restriccionesVioladas(Individual<String> individual, Map<String, List<Integer>> restricciones){
        List<String> turnos = individual.getRepresentation();
        int nRestricciones = 0;
        int i=0;
        for(String turno : turnos){
            if(!(turno.equals("VACIO")) && restricciones.get(turno)!=null && restricciones.get(turno).contains(i)){
                nRestricciones ++;
            }
            i++;
        }
        return nRestricciones;
    }
}
