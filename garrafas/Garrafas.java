package garrafas;

import aima.core.agent.Action;
import aima.core.agent.impl.DynamicAction;

public class Garrafas {

	// Acciones

	public static Action LLENA1 = new DynamicAction("Llena1");

	public static Action LLENA2 = new DynamicAction("Llena2");

	public static Action VACIA1 = new DynamicAction("Vacia1");

	public static Action VACIA2 = new DynamicAction("Vacia2");

	public static Action DE1A2 = new DynamicAction("De1a2");

	public static Action DE2A1 = new DynamicAction("De2a1");

	// Componentes del estado
	
	public int contenido1 = 0, contenido2 = 0;

	// Contexto del problema
	public static final int max1 = 5, max2 = 3;

	public static final int goal = 4;

	//Constructores
	public Garrafas(){}

	public Garrafas(int c1, int c2){
		contenido1 = c1;
		contenido2 = c2;
	}

	public Garrafas(Garrafas copy) {
		this(copy.contenido1, copy.contenido2);
	}

	public boolean isGoalState() {
		return contenido1 == goal || contenido2 == goal;
	}

	public boolean equals(Object o) {

		if (this == o) {
			return true;
		}
		if ((o == null) || (this.getClass() != o.getClass())) {
			return false;
		}
		return this.contenido1 == ((Garrafas) o).contenido1
				&& this.contenido2 == ((Garrafas) o).contenido2;
	}

	public int hashCode() {
		return this.contenido1 + 31 * this.contenido2;
	}

	public String toString() {
		return "(" + this.contenido1 + "/" + max1 + ", " + this.contenido2
				+ "/" + max2 + ")";
	}

	public void llena1(){
		contenido1 = max1;
	}

	public void llena2(){
		contenido2 = max2;
	}

	public void vacia1(){
		contenido1 = 0;
	}

	public void vacia2(){
		contenido2 = 0;
	}

	public void de1a2(){
		int auxCont2 = contenido2;
		contenido2 = Math.min(contenido1 + contenido2, max2);
		contenido1 = contenido1 + auxCont2 - contenido2;
	}

	public void de2a1(){
		int auxCont1 = contenido1;
		contenido1 = Math.min(contenido1 + contenido2, max1);
		contenido2 = contenido2 + auxCont1 - contenido1;
	}
	
	public boolean canApply(Action action) {
		if (contenido1==0 && (action==VACIA1 || action==DE1A2) ||
			contenido2==0 && (action==VACIA2 || action==DE2A1) ||
			contenido1==max1 && (action==LLENA1 || action==DE2A1) ||
			contenido2==max2 && (action==LLENA2 || action==DE1A2)){
			return false;
		}
		return true;
	}
}
