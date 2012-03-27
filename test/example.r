# y mntl. Rate
# f Franchise
# s Selbstbehalt
# m Selbstbehalt max.

png('insurance.png')

costf <- function(y, f, s=0.1, m=700) {
  return(function(x) {
    (y * 12) + min(f, x) + max(0, min(m - f, s * (max(f, x) - f)))
  })
}

f0 <- costf( 95.70, 0 )
f1 <- costf( 90.00, 100 )
f2 <- costf( 84.10, 200 )
f4 <- costf( 72.40, 400 )
f6 <- costf( 60.70, 600 )

x_max <- 7250
x <- seq(0, x_max, by=10)
plot(x, x, type='l', lty=3,
         xlim=range(0, x_max),
         ylim=range(500, 2000),
         xlab='Kosten Verursacht',
         ylab='Kosten Gezahlt')

lines(x, apply(array(x), 1, f0), col='green')
lines(x, apply(array(x), 1, f1))
lines(x, apply(array(x), 1, f2))
lines(x, apply(array(x), 1, f4))
lines(x, apply(array(x), 1, f6), col='red')

f <- function(x) { return(f0(x) - f6(x)) }
lower <- uniroot(f, c(400, 600))
upper <- uniroot(f, c(2500, 3000))
abline(v=lower$root, lty=2)
abline(v=upper$root, lty=2)
