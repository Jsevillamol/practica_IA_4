package turnos;

import aima.core.search.framework.problem.GoalTest;
import aima.core.search.local.FitnessFunction;
import aima.core.search.local.GeneticAlgorithm;
import aima.core.search.local.Individual;

import java.util.*;

public class TurnosDemo {


    /*PROBLEM DATA*/
    public static final int nExamenes = 8;
    public static final int nTurnos = 16;

    // Lista de profesores, mas un simbolo especial al final para representar el turno vacío
    public static final List<String> profesorado = Arrays.asList("ANA", "BONIATO", "CARLA", "DOMINGO", "ELISA", "FEDERICO", "GERTRUDIS", "VACIO");
    public static final int nProfesores = profesorado.size();
    public static final Map<String, List<Integer>> restricciones = new HashMap<>();
    public static final Map<String, List<Integer>> preferencias = new HashMap<>();

    static {
        TurnosDemo.restricciones.put("ANA", Arrays.asList(1, 2, 3));
        TurnosDemo.preferencias.put("ANA", Arrays.asList(1, 2, 3));
    }

    public static void main(String[] args) {
        GeneticAlgorithmSearchDemo();
    }

    private static void GeneticAlgorithmSearchDemo() {
        System.out.println("\nTurnos Demo GeneticAlgorithm  -->");

        FitnessFunction<String> fitnessFunction = new TurnosFitnessFunction(profesorado,
                restricciones,
                preferencias,
                nTurnos);
        GoalTest goalTest = new TurnosGoalTest((TurnosFitnessFunction) fitnessFunction, restricciones,
                nExamenes);
        // Generate an initial population
        Set<Individual<String>> population = new HashSet<>();
        for (int i = 0; i < TurnosUtil.POBLACION_INICIAL; i++) {
            population.add(TurnosUtil.generateRandomIndividual(profesorado,
                    nExamenes,
                    nTurnos));
        }

        GeneticAlgorithm<String> ga = new GeneticAlgorithm<>(
                nTurnos,
                profesorado,
                0.15);

        // Run for a set amount of time
        Individual<String> bestIndividual = ga.geneticAlgorithm(population, fitnessFunction, goalTest, 1000L);

        TurnosUtil.showInfo(ga, bestIndividual, fitnessFunction, goalTest,
                nTurnos, nExamenes, nProfesores);


        // Run till goal is achieved
        bestIndividual = ga.geneticAlgorithm(population, fitnessFunction, goalTest, 0L);

        TurnosUtil.showInfo(ga, bestIndividual, fitnessFunction, goalTest,
                nTurnos, nExamenes, nProfesores);
    }

}
