package aima.core.search.local;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Random;

import aima.core.search.local.GeneticAlgorithm;
import aima.core.search.local.Individual;
import aima.core.search.local.FitnessFunction;

public class CustomGeneticAlgorithm<A> extends GeneticAlgorithm {

	//Parte obligatoria
	/**Probability of creating a crossed baby for next generation instead of just passing a non-crossed individual*/
	protected double crossProbability = 1.0;
	/**Create two children per cross*/
	protected boolean siblingsStrategy = false;
	/**Allways use the children (as oposed to use the best between parents and children in each cross)*/
	protected boolean destructiveStrategy = true;

	// Parte opcional
	/**In a cross, cut the genome in two points to cross it*/
	protected boolean twoPointCross = false;
	/**If false, we use allele random substitution instead*/
	protected boolean alleleExchangeMutation = false;

	enum SelectionMechanism {MONTECARLO, ELITIST, TOURNAMENT};
	protected SelectionMechanism selectionMechanism = MONTECARLO;
	/**If performing tournament selection, this is the probability of the worst individual winning the torunament */
	protected double underdogProbability = 0.0;


	/**Primitive operation which is responsible for creating the next generation.*/
	@Override
	protected List<Individual<A>> nextGeneration(List<Individual<A>> population, FitnessFunction<A> fitnessFn) {
		// new_population <- empty set
		List<Individual<A>> newPopulation = new ArrayList<Individual<A>>(population.size());

		// Generate children
		while (newPopulation.size() < population.size()){

			if(random.nextDouble() <= crossProbability){// Perform a cross

				List<Individual<A>> children = new ArrayList<>();

				// x <- RANDOM-SELECTION(population, FITNESS-FN)
				Individual<A> x = randomSelection(population, fitnessFn);
				// y <- RANDOM-SELECTION(population, FITNESS-FN)
				Individual<A> y = randomSelection(population, fitnessFn);

				// children <- REPRODUCE(x, y)
				children = reproduce(x, y);

				if(!destructiveStrategy){
					// Between children and parents, selects the one with greatest fitness
					children.add(x);
					children.add(y);

					children.sort((i1,i2)->fitnessFn.apply(i1) < fitnessFn.apply(i2));

					children.remove(children.size()-1);
					children.remove(children.size()-1);
				}

				for(int i = 0; i < children.size() && newPopulation.size() < population.size(); i++){
					auto child = children.get(i);
					child = maybeMutate(child);
					newPopulation.add(child);
				}

			} else { // Don't cross
				Individual<A> child = randomSelection(population, fitnessFn);
				child = maybeMutate(child);
				newPopulation.add(child);
			}

		}
	}

	protected Individual<A> maybeMutate(Individual<A> child){
		// if (small random probability) then child <- MUTATE(child)
		if (random.nextDouble() <= mutationProbability) {
			child = mutate(child);
		}

		return child;
	}

	// RANDOM-SELECTION(population, FITNESS-FN)
	@Override
	protected Individual<A> randomSelection(List<Individual<A>> population, FitnessFunction<A> fitnessFn) {
		// Default result is last individual
		// (just to avoid problems with rounding errors)
		Individual<A> selected = population.get(population.size() - 1);
	

		switch(selectionMechanism){
			case MONTECARLO:

				// Determine all of the fitness values
				double[] fValues = new double[population.size()];
				for (int i = 0; i < population.size(); i++) {
					fValues[i] = fitnessFn.apply(population.get(i));
				}
				// Normalize the fitness values
				fValues = Util.normalize(fValues);

				double prob = random.nextDouble();
				double totalSoFar = 0.0;
				for (int i = 0; i < fValues.length; i++) {
					// Are at last element so assign by default
					// in case there are rounding issues with the normalized values
					totalSoFar += fValues[i];
					if (prob <= totalSoFar) {
						selected = population.get(i);
						break;
					}
				}

				break;

			case ELITIST:
				break;

			case TOURNAMENT:
				Individual<A> contestant1 = population.get( Random.nextInt(population.size()) );
				Individual<A> contestant2 = population.get( Random.nextInt(population.size()) );
				double prob = random.nextDouble();
				if (prob < underdogProbability){
					// the underdog wins
					selected = (fitnessFn.apply(contestant1) < fitnessFn.apply(contestant2)) ? contestant1 : contestant2;
				} else {
					// the best individual wins
					selected = (fitnessFn.apply(contestant1) < fitnessFn.apply(contestant2)) ? contestant2 : contestant1;
				}

			break;

			default:
				println("ERROR. SELECTION MECHANISM NOT IMPLEMENTED");

		}


		selected.incDescendants();
		return selected;
	}


	// function REPRODUCE(x, y) returns a list of individuals
	// inputs: x, y, parent individuals
	protected List<Individual<A>> reproduce(Individual<A> x, Individual<A> y) {

		List<Individual<A>> children = new ArrayList<>();

		// n <- LENGTH(x);
		// Note: this is = this.individualLength
		// c <- random number from 1 to n
		int c = randomOffset(individualLength);

		if(twoPointCross){
			int c2 = c + randomOffset(individualLength - c);
		}

		// return APPEND(SUBSTRING(x, 1, c), SUBSTRING(y, c+1, n))
		List<A> childRepresentation = new ArrayList<A>();

		if(!twoPointCross){
			childRepresentation.addAll(x.getRepresentation().subList(0, c));
			childRepresentation.addAll(y.getRepresentation().subList(c, individualLength));
		} else {
			childRepresentation.addAll(x.getRepresentation().subList(0, c));
			childRepresentation.addAll(y.getRepresentation().subList(c, c2));
			childRepresentation.addAll(x.getRepresentation().subList(c2, individualLength));
		}

		Individual<A> child = new Individual<A>(childRepresentation);
		children.add(child);

		if(siblingsStrategy){
			List<A> child2Representation = new ArrayList<A>();

			if(!twoPointCross){
				child2Representation.addAll(y.getRepresentation().subList(0, c));
				child2Representation.addAll(x.getRepresentation().subList(c, individualLength));
			} else {
				child2Representation.addAll(y.getRepresentation().subList(0, c));
				child2Representation.addAll(x.getRepresentation().subList(c, c2));
				child2Representation.addAll(y.getRepresentation().subList(c2, individualLength));
			}

			Individual<A> child2 = new Individual<A>(child2Representation);
			children.add(child2);
		}

		return children;
	}

	@Override
	protected Individual<A> mutate(Individual<A> child) {

		List<A> mutatedRepresentation = new ArrayList<A>(child.getRepresentation());

		if(!alleleExchangeMutation){
			// Random replacement
			int mutateOffset = randomOffset(individualLength);
			int alphaOffset = randomOffset(finiteAlphabet.size());
			mutatedRepresentation.set(mutateOffset, finiteAlphabet.get(alphaOffset));
		} else {
			// Alelo exchange
			int alleleIndex1 = randomOffset(individualLength);
			int alleleIndex2 = randomOffset(individualLenght);

			A allele1 = mutatedRepresentation.get(alleleIndex1);
			A allele2 = mutatedRepresentation.get(alleleIndex1);

			mutatedRepresentation.put(alleleIndex1, allele2);
			mutatedRepresentation.put(alleleIndex2, allele1);

		}

		Individual<A> mutatedChild = new Individual<A>(mutatedRepresentation);

		return mutatedChild;
	}

}
