package turnos;

import aima.core.search.local.FitnessFunction;
import aima.core.search.local.Individual;

import java.util.List;
import java.util.Map;

public class TurnosFitnessFunction implements FitnessFunction<String> {

    private double restrictionsWeight = 4.0;

    static private boolean preferenciasOrdenadas = false;	// si es true, las preferencias con índices más bajos añaden más utilidad
    static private boolean turnosConsecutivos = false;		// si es true, la asignacion de turnos consecutivos da mas fitness

    private int nTurnos;
    private int nExamenes;
    public List<String> profesorado;
    private Map<String, List<Integer>> restricciones;
    private Map<String, List<Integer>> preferencias;


    public TurnosFitnessFunction(List<String> profesorado, Map<String, List<Integer>> restricciones,
                                 Map<String, List<Integer>> preferencias, int nTurnos, int nExamenes){
        this.profesorado = profesorado;
        this.restricciones = restricciones;
        this.preferencias = preferencias;
        this.nTurnos = nTurnos;
        this.nExamenes = nExamenes;
    }

    @Override
    public double apply(Individual<String> individual) {
        double fitness = preferenciasFitness(individual);
        fitness +=  restrictionsWeight*(nTurnos - TurnosUtil.restriccionesVioladas(individual, restricciones));
        fitness += TurnosUtil.equilibrioFitness(individual, profesorado);
        int turnosNoVacios = TurnosUtil.contarTurnosNoVacios(individual);
        fitness += 8*(nTurnos-Math.abs(nExamenes-turnosNoVacios));//Gran penalizacion
        if(turnosConsecutivos) fitness += TurnosUtil.turnosConsecutivosAsignados(individual);
        return fitness;
    }

    /**Calcula cuantas preferencias satisface esta asignación
     * Si preferenciasOrdenadas = true, entonces da más importancia a las preferencias con indices mas bajos de cada profesor
     */
    private int preferenciasFitness(Individual<String> individual){
        List<String> turnos = individual.getRepresentation();
        int nPreferencias = 0;
        int i = 0;
        for(String turno : turnos){
            if(!(turno.equals("VACIO")) && preferencias.get(turno)!=null && preferencias.get(turno).contains(i)){
                if(!preferenciasOrdenadas)
                    nPreferencias++;
                else
                    nPreferencias += nTurnos - preferencias.get(turno).indexOf(i);
            }
            i++;
        }
        return nPreferencias;
    }

}
