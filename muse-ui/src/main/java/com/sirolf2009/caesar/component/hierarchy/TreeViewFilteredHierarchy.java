package com.sirolf2009.caesar.component.hierarchy;

import javafx.beans.property.ObjectProperty;
import javafx.beans.property.SimpleObjectProperty;
import javafx.collections.ObservableList;
import javafx.collections.transformation.FilteredList;
import javafx.scene.control.TreeItem;

import java.util.function.Predicate;

public class TreeViewFilteredHierarchy extends TreeViewHierarchy {

    private ObjectProperty<Predicate> predicate;

    @Override public void setItems(ObservableList items) {
        super.setItems(new FilteredList(items, getItemPredicate()));
        itemPredicateProperty().addListener(e -> getItems().setPredicate(getItemPredicate()));
    }

    @Override public FilteredList getItems() {
        if(predicate == null) {
            predicate = new SimpleObjectProperty<>(null);
        }
        return (FilteredList) super.getItems();
    }

    public ObjectProperty<Predicate> itemPredicateProperty() {
        return predicate;
    }

    public Predicate getItemPredicate() {
        if(predicate == null) {
            predicate = new SimpleObjectProperty<>(null);
        }
        return predicate.get();
    }

}
