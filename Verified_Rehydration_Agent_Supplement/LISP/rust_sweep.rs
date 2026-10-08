// AGT-VRA-001 Specification §12 reconstructed idiomatically in Rust (2010 lineage),
// from the specification alone -- the 2010 endpoint of the temporal span.
fn next_state(s: u8, t: char, g: bool) -> Option<u8> {
    if t == 'e' { return Some(5); }          // rollback: blocking priority over every rule
    if s == 6 { return Some(6); }            // OR-11: S6 terminal on projection surface
    let (pass, fail) = match (s, t) {
        (0,'a')=>(1,5), (1,'b')=>(2,5), (2,'c')=>(3,5), (3,'d')=>(4,5),
        (3,'f')=>(6,6), (5,'g')=>(7,5), (7,'h')=>(8,5), (8,'i')=>(0,8),
        _ => return None,                    // unmapped: fail-closed
    };
    Some(if g { pass } else { fail })
}
fn main() {
    let mut out = String::new();
    for s in 0..9u8 {
        for t in "abcdefghi".chars() {
            for g in [true, false] {
                match next_state(s, t, g) {
                    Some(n) => out.push_str(&n.to_string()),
                    None => out.push('E'),
                }
                out.push('\n');
            }
        }
    }
    print!("{}", out);
}
