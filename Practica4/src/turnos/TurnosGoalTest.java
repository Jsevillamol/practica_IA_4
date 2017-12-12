package turnos;

import aima.core.search.framework.problem.GoalTest;
import aima.core.search.local.Individual;

import java.util.List;
import java.util.Map;

public class TurnosGoalTest implements GoalTest {

    private TurnosFitnessFunction fitnessFunction;
    private Map<String, List<Integer>> restricciones;
    private int nExamenes;

    public TurnosGoalTest(TurnosFitnessFunction fitnessFunction,
                          Map<String, List<Integer>> restricciones,
                          int nExamenes){
        this.restricciones = restricciones;
        this.fitnessFunction = fitnessFunction;
        this.nExamenes = nExamenes;
    }

    @Override
    public boolean isGoalState(Object state) {
        @SuppressWarnings("unchecked")
        Individual<String> individuo = (Individual<String>) state;
        boolean restriccionesRespetadas = TurnosUtil.restriccionesVioladas(individuo, restricciones) == 0;
        boolean examenesCubiertos = TurnosUtil.contarTurnosNoVacios(individuo) == nExamenes;
        return restriccionesRespetadas && examenesCubiertos;
    }
}
