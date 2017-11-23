package garrafas;

import aima.core.agent.Action;
import aima.core.search.framework.SearchAgent;
import aima.core.search.framework.SearchForActions;
import aima.core.search.framework.problem.Problem;
import aima.core.search.framework.problem.ResultFunction;
import aima.core.search.framework.qsearch.GraphSearch;
import aima.core.search.framework.qsearch.TreeSearch;
import aima.core.search.informed.AStarSearch;
import aima.core.search.informed.GreedyBestFirstSearch;
import aima.core.search.uninformed.BreadthFirstSearch;
import aima.core.search.uninformed.DepthFirstSearch;
import aima.core.search.uninformed.UniformCostSearch;

import java.util.List;
import java.util.Properties;


public class GarrafasDemo {

	private static Garrafas example = new Garrafas();

	private static class GarrafasProblem extends Problem {

		public GarrafasProblem(Garrafas initialState) {
			super(initialState, GarrafasFunctionFactory.getActionsFunction(), GarrafasFunctionFactory.getResultFunction(),
					new GarrafasGoalTest());
		}
	}

	public static void main(String[] args) {
		garrafasTreeBFSDemo();
		garrafasGraphBFSDemo();
		garrafasGraphDFSDemo();
		garrafasTreeUCSDemo();
		garrafasGraphUCSDemo();
		garrafasGraphGreedyDemo();
		garrafasTreeAStarDemo();
		garrafasGraphAStarDemo();
	}

	//Demos

	private static void garrafasTreeBFSDemo() {
		System.out.println("\nGarrafasDemo Tree BFS -->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new BreadthFirstSearch(new TreeSearch());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static void garrafasGraphBFSDemo() {
		System.out.println("\nGarrafasDemo Graph BFS -->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new BreadthFirstSearch(new GraphSearch());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static void garrafasGraphDFSDemo() {
		System.out.println("\nGarrafasDemo Graph DFS -->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new DepthFirstSearch(new GraphSearch());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static void garrafasTreeUCSDemo() {
		System.out.println("\nGarrafasDemo Tree UCS -->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new UniformCostSearch(new TreeSearch());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static void garrafasGraphUCSDemo() {
		System.out.println("\nGarrafasDemo Graph UCS -->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new UniformCostSearch(new GraphSearch());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static void garrafasGraphGreedyDemo() {
		System.out.println("\nGarrafas Graph Greedy Best First Search (CustomHeuristic)-->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new GreedyBestFirstSearch
					(new GraphSearch(), new GarrafasHeuristicFunction());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static void garrafasTreeAStarDemo() {
		System.out.println("\nGarrafas Tree A* Search (CustomHeuristic)-->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new AStarSearch
					(new TreeSearch(), new GarrafasHeuristicFunction());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static void garrafasGraphAStarDemo() {
		System.out.println("\nGarrafas Graph A* Search (CustomHeuristic)-->");
		try {
			Problem problem = new GarrafasProblem(example);
			SearchForActions search = new AStarSearch
					(new GraphSearch(), new GarrafasHeuristicFunction());
			long startTime = System.nanoTime();
			SearchAgent agent = new SearchAgent(problem, search);
			long endTime = System.nanoTime();
			printActions(agent.getActions());
			printInstrumentation(agent.getInstrumentation());
			long elapsedTime = endTime - startTime;
			System.out.println("Time: " + elapsedTime + " ns");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	/*
	 * Utils
	 */

	private static void printInstrumentation(Properties properties) {
		for (Object o : properties.keySet()) {
			String key = (String) o;
			String property = properties.getProperty(key);
			System.out.println(key + " : " + property);
		}

	}

	private static void printActions(List<Action> actions) {
		Garrafas state = new Garrafas();
		ResultFunction resultFunction = GarrafasFunctionFactory.getResultFunction();
		System.out.println(state);
		for(Action action : actions){
			System.out.println(action);
			state = (Garrafas) resultFunction.result(state, action);
			System.out.println(state);
		}
	}
}