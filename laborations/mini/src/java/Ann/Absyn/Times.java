package Ann.Absyn; // Java Package generated by the BNF Converter.

public class Times  extends Op {
  public Times() { }

  public <R,A> R accept(Ann.Absyn.Op.Visitor<R,A> v, A arg) { return v.visit(this, arg); }

  public boolean equals(Object o) {
    if (this == o) return true;
    if (o instanceof Ann.Absyn.Times) {
      return true;
    }
    return false;
  }

  public int hashCode() {
    return 37;
  }


}