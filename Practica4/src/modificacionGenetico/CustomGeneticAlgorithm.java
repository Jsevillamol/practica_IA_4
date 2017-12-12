package modificacionGenetico;

import aima.core.search.local.FitnessFunction;
import aima.core.search.local.GeneticAlgorithm;
import aima.core.search.local.Individual;
import aima.core.util.Util;

import java.util.*;

public class CustomGeneticAlgorithm extends GeneticAlgorithm<String> {

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

    enum SelectionMechanism {MONTECARLO, ELITIST, TOURNAMENT}
    protected SelectionMechanism selectionMechanism = SelectionMechanism.MONTECARLO;
    /**If performing tournament selection, this is the probability of the worst individual winning the torunament */
    protected double underdogProbability = 0.0;

    public CustomGeneticAlgorithm(int individualLength, Collection<String> finiteAlphabet, double mutationProbability) {
        super(individualLength, finiteAlphabet, mutationProbability, new Random());
    }


    /**Primitive operation which is responsible for creating the next generation.*/
    protected List<Individual<String>> nextGeneration(List<Individual<String>> population, FitnessFunction<String> fitnessFn) {
        // new_population <- empty set
        List<Individual<String>> newPopulation = new ArrayList<Individual<String>>(population.size());

        // Generate children
        while (newPopulation.size() < population.size()){

            if(random.nextDouble() <= crossProbability){// Perform a cross

                List<Individual<String>> children = new ArrayList<>();

                // x <- RANDOM-SELECTION(population, FITNESS-FN)
                Individual<String> x = randomSelection(population, fitnessFn);
                // y <- RANDOM-SELECTION(population, FITNESS-FN)
                Individual<String> y = randomSelection(population, fitnessFn);

                // children <- REPRODUCE_MANY(x, y)
                children = reproduceMany(x, y);

                if(!destructiveStrategy){
                    // Between children and parents, selects the one with greatest fitness
                    children.add(x);
                    children.add(y);

                    children.sort(Comparator.comparingDouble(fitnessFn::apply));

                    children.remove(children.size()-1);
                    children.remove(children.size()-1);
                }

                for(Individual<String> child : children)
                    newPopulation.add(maybeMutate(child));

            } else { // Don't cross
                Individual<String> child = randomSelection(population, fitnessFn);
                child = maybeMutate(child);
                newPopulation.add(child);
            }

        }
        return newPopulation;
    }

    protected Individual<String> maybeMutate(Individual<String> child){
        // if (small random probability) then child <- MUTATE(child)
        if (random.nextDouble() <= mutationProbability) {
            child = mutate(child);
        }

        return child;
    }

    // RANDOM-SELECTION(population, FITNESS-FN)
    @Override
    protected Individual<String> randomSelection(List<Individual<String>> population, FitnessFunction<String> fitnessFn) {
        // Default result is last individual
        // (just to avoid problems with rounding errors)
        Individual<String> selected = population.get(population.size() - 1);


        switch(selectionMechanism){
            case MONTECARLO:

                // Determine all of the fitness values
                double[] fValues = new double[population.size()];
                for (int i = 0; i < population.size(); i++) {
                    fValues[i] = fitnessFn.apply(population.get(i));
                }
                // Normalize the fitness values
                fValues = Util.normalize(fValues);

                double probability = random.nextDouble();
                double totalSoFar = 0.0;
                for (int i = 0; i < fValues.length; i++) {
                    // Are at last element so assign by default
                    // in case there are rounding issues with the normalized values
                    totalSoFar += fValues[i];
                    if (probability <= totalSoFar) {
                        selected = population.get(i);
                        break;
                    }
                }

                break;

            case ELITIST:
                break;

            case TOURNAMENT:
                Individual<String> contestant1 = population.get( random.nextInt(population.size()) );
                Individual<String> contestant2 = population.get( random.nextInt(population.size()) );
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
                System.err.println("ERROR. SELECTION MECHANISM NOT IMPLEMENTED");

        }


        selected.incDescendants();
        return selected;
    }


    // function REPRODUCE_MANY(mam, dad) returns a list of individuals
    // inputs: mam, dad, parent individuals
    protected List<Individual<String>> reproduceMany(Individual<String> mam, Individual<String> dad) {

        List<Individual<String>> children = new ArrayList<>();

        // n <- LENGTH(x);
        // Note: this is = this.individualLength
        // point1 <- random number from 1 to n
        int point1 = randomOffset(individualLength);
        int point2 = point1;
        if(twoPointCross){
            point2 += randomOffset(individualLength - point1);
        }

        // return APPEND(SUBSTRING(x, 1, c), SUBSTRING(y, c+1, n))
        children.add(cross(mam, dad, point1, point2));

        if(siblingsStrategy)
            children.add(cross(dad, mam, point1, point2));

        return children;
    }

    /**Cruza los dos padres por dos puntos.
     * Si los dos puntos son iguales se hace un solo cruce*/
    private Individual<String> cross(Individual<String> mam, Individual<String> dad,
                                     int point1, int point2) {
        List<String> childRepresentation = new ArrayList<>();
        childRepresentation.addAll(mam.getRepresentation().subList(0,      point1));
        childRepresentation.addAll(dad.getRepresentation().subList(point1, point2));
        childRepresentation.addAll(mam.getRepresentation().subList(point2, individualLength));

        return new Individual<String>(childRepresentation);
    }

    @Override
    protected Individual<String> mutate(Individual<String> child) {

        List<String> mutatedRepresentation = new ArrayList<>(child.getRepresentation());

        if(!alleleExchangeMutation){
            // Random replacement
            int mutateOffset = randomOffset(individualLength);
            int alphaOffset = randomOffset(finiteAlphabet.size());
            mutatedRepresentation.set(mutateOffset, finiteAlphabet.get(alphaOffset));
        } else {
            // Alelo exchange
            int alleleIndex1 = randomOffset(individualLength);
            int alleleIndex2 = randomOffset(individualLength);

            String allele1 = mutatedRepresentation.get(alleleIndex1);
            String allele2 = mutatedRepresentation.get(alleleIndex1);

            mutatedRepresentation.set(alleleIndex1, allele2);
            mutatedRepresentation.set(alleleIndex2, allele1);

        }

        Individual<String> mutatedChild = new Individual<String>(mutatedRepresentation);

        return mutatedChild;
    }

}