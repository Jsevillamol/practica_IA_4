package garrafas;

import aima.core.search.framework.evalfunc.HeuristicFunction;
import aima.core.search.framework.problem.ResultFunction;

public class GarrafasHeuristicFunction implements HeuristicFunction {

	private ResultFunction resultFunction = GarrafasFunctionFactory.getResultFunction();

	@Override
	public double h(Object state) {
		Garrafas garrafas = (Garrafas) state;
		Garrafas lookAhead1 = (Garrafas) resultFunction.result(state, Garrafas.DE1A2);
		Garrafas lookAhead2 = (Garrafas) resultFunction.result(state, Garrafas.DE1A2);
		if (garrafas.isGoalState()) return 0;
		// Asumimos que max1 y max2 son distintos de goal, 
		// por lo que solo las acciones de trasvase pueden resultar en el objetivo
		else if (lookAhead1.isGoalState() || lookAhead2.isGoalState()) return 1; 
		else return 2;
	}

}
