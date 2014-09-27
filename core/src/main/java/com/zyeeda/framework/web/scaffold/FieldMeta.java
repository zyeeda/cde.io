package com.zyeeda.framework.web.scaffold;

/**
 * @author guyong
 * 
 */
public class FieldMeta {

    private String name = null;
    private Class<?> type = null;
    private boolean entity = false;
    
    private boolean manyToManyOwner = false;
    private Class<?> manyToManyTarget = null;


    public FieldMeta(String name, Class<?> type, boolean entity, boolean manyToManyOwner, Class<?> manyToManyTarget) {
        this.name = name;
        this.type = type;
        this.entity = entity;
        this.manyToManyOwner = manyToManyOwner;
        this.manyToManyTarget = manyToManyTarget;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Class<?> getType() {
        return type;
    }

    public void setType(Class<?> type) {
        this.type = type;
    }

    public boolean isEntity() {
        return entity;
    }

    public void setEntity(boolean entity) {
        this.entity = entity;
    }

    public boolean isManyToManyOwner() {
        return manyToManyOwner;
    }

    public void setManyToManyOwner(boolean manyToManyOwner) {
        this.manyToManyOwner = manyToManyOwner;
    }

    public Class<?> getManyToManyTarget() {
        return manyToManyTarget;
    }

    public void setManyToManyTarget(Class<?> manyToManyTarget) {
        this.manyToManyTarget = manyToManyTarget;
    }

}