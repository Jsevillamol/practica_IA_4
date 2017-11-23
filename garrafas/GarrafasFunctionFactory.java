package garrafas;

import java.util.LinkedHashSet;
import java.util.Set;

import aima.core.agent.Action;
import aima.core.search.framework.problem.ActionsFunction;
import aima.core.search.framework.problem.ResultFunction;

public class GarrafasFunctionFactory {
	
	private static ActionsFunction _actionsFunction = null;
	private static ResultFunction _resultFunction = null;

	public static ActionsFunction getActionsFunction() {
		if (null == _actionsFunction) {
			_actionsFunction = new GarrafasActionsFunction();
		}
		return _actionsFunction;
	}
	
	public static ResultFunction getResultFunction() {
		if (null == _resultFunction) {
			_resultFunction = new GarrafasResultFunction();
		}
		return _resultFunction;
	}
	
	private static class GarrafasActionsFunction implements ActionsFunction {

		@Override
		public Set<Action> actions(Object o) {
			if (o==null || !(o instanceof Garrafas)) {
				return null;
			}
			Garrafas garrafas = (Garrafas) o;
			Set<Action> actions = new LinkedHashSet<Action>();
			
			if (garrafas.canApply(Garrafas.LLENA1)) {
				actions.add(Garrafas.LLENA1);
			}
			if (garrafas.canApply(Garrafas.LLENA2)) {
				actions.add(Garrafas.LLENA2);
			}
			if (garrafas.canApply(Garrafas.VACIA1)) {
				actions.add(Garrafas.VACIA1);
			}
			if (garrafas.canApply(Garrafas.VACIA2)) {
				actions.add(Garrafas.VACIA2);
			}
			if (garrafas.canApply(Garrafas.DE1A2)) {
				actions.add(Garrafas.DE1A2);
			}
			if (garrafas.canApply(Garrafas.DE2A1)) {
				actions.add(Garrafas.DE2A1);
			}
			return actions;
		}
		
	}

	private static class GarrafasResultFunction implements ResultFunction {

		@Override
		public Object result(Object o, Action action) {
			if (o==null || !(o instanceof Garrafas)) {
				return null;
			}
			Garrafas garrafas = new Garrafas((Garrafas) o);
			
			if (action.equals(Garrafas.LLENA1) && garrafas.canApply(action)){
				garrafas.llena1();
			} else if (action.equals(Garrafas.LLENA2) && garrafas.canApply(action)){
				garrafas.llena2();
			} else if (action.equals(Garrafas.DE1A2) && garrafas.canApply(action)){
				garrafas.de1a2();
			} else if (action.equals(Garrafas.DE2A1) && garrafas.canApply(action)){
				garrafas.de2a1();
			} else if (action.equals(Garrafas.VACIA1) && garrafas.canApply(action)){
				garrafas.vacia1();
			} else if (action.equals(Garrafas.VACIA2) && garrafas.canApply(action)){
				garrafas.vacia2();
			} else {
				//If the Action is not understood the result will be the current state.
				garrafas = (Garrafas) o;
			}
			return garrafas;
		}
		
	}
}





















