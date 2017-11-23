package garrafas;

import aima.core.search.framework.problem.GoalTest;

//This class seems to be done

public class GarrafasGoalTest implements GoalTest {


	@Override
	public boolean isGoalState(Object state) {
		return ((Garrafas) state).isGoalState();
	}

}