package genetico.turnos;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Set;

import aima.core.search.framework.problem.GoalTest;
import aima.core.search.local.FitnessFunction;
import aima.core.search.local.GeneticAlgorithm;
import aima.core.search.local.Individual;

/**
 * @author Jaime Sevilla
 * @author David Rubio
 */

public class TurnosDemo {

	public static void main(String[] args) {

		GeneticAlgorithmSearchDemo();
	}

	public static void GeneticAlgorithmSearchDemo() {
		System.out.println("\nTurnos Demo GeneticAlgorithm  -->");
		try {
			FitnessFunction<Profesor> fitnessFunction = TurnosGenAlgoUtil.getFitnessFunction();
			GoalTest goalTest = TurnosGenAlgoUtil.getGoalTest();
			// Generate an initial population
			Set<Individual<Profesor>> population = new HashSet<Individual<Profesor>>();
			for (int i = 0; i < 50; i++) {
				population.add(TurnosGenAlgoUtil.generateRandomIndividual(boardSize));
			}

			GeneticAlgorithm<Profesor> ga = new GeneticAlgorithm<Profesor>(boardSize,
					TurnosGenAlgoUtil.getFiniteAlphabet()), 0.15);

			// Run for a set amount of time
			Individual<Profesor> bestIndividual = ga.geneticAlgorithm(population, fitnessFunction, goalTest, 1000L);

			System.out.println("Max Time (1 second) Best Individual=\n"
					+ bestIndividual);
			System.out.println("nTurnos      = " + TurnosGenAlgoUtil.nTurnos);
			System.out.println("nExamenes      = " + TurnosGenAlgoUtil.nExamenes);
			System.out.println("# Possible individuals = " + (
				new BigDecimal(TurnosGenAlgoUtil.nTurnos)).pow(TurnosGenAlgoUtil.NPROFESORES + 1));
			System.out.println("Fitness         = " + fitnessFunction.apply(bestIndividual));
			System.out.println("Is Goal         = " + goalTest.isGoalState(bestIndividual));
			System.out.println("Population Size = " + ga.getPopulationSize());
			System.out.println("Iterations       = " + ga.getIterations());
			System.out.println("Took            = " + ga.getTimeInMilliseconds() + "ms.");

			// Run till goal is achieved
			bestIndividual = ga.geneticAlgorithm(population, fitnessFunction, goalTest, 0L);

			System.out.println("");
			System.out
					.println("Goal Test Best Individual=\n" + bestIndividual);
			System.out.println("nTurnos      = " + TurnosGenAlgoUtil.nTurnos);
			System.out.println("nExamenes      = " + TurnosGenAlgoUtil.nExamenes);
			System.out.println("# Possible individuals = " + (
				new BigDecimal(TurnosGenAlgoUtil.nTurnos)).pow(TurnosGenAlgoUtil.NPROFESORES + 1));
			System.out.println("Fitness         = " + fitnessFunction.apply(bestIndividual));
			System.out.println("Is Goal         = " + goalTest.isGoalState(bestIndividual));
			System.out.println("Population Size = " + ga.getPopulationSize());
			System.out.println("Iterations       = " + ga.getIterations());
			System.out.println("Took            = " + ga.getTimeInMilliseconds() + "ms.");

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}