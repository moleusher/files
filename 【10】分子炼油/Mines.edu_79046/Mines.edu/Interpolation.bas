Attribute VB_Name = "Module_Interpolation"
Option Explicit

Function Interpolate _
    (X_Value As Variant, Known_Xs As Object, Known_Ys As Object) _
As Variant
Attribute Interpolate.VB_Description = "Function to interpolate set of x vs. y date (known_xs & known_ys) for a given x_value."
'
'   Function to do linear interpolation in a table.
'
'   Written 07/06/2001 (J.L. Jechura).
'   Modified 10/24/2002 (JL Jechura) to split up the Excel specific code from the general
'       array code.
'   Modified 10/29/2008 (JL Jechura). Check that the X_Value array is in monotonic
'       ascending or descending order. If not, return error code.
'
Dim nValues As Integer, i As Integer, bAscend As Boolean
Dim Xs() As Variant, Ys() As Variant

'
'   Ensure that the x & y arrays have the same sizes.
    nValues = Known_Xs.Count
    If ((nValues <> Known_Ys.Count) Or (nValues <= 1)) Then
        Interpolate = "#ArrayLengths!"
        Exit Function
    End If

'
'   Copy values from cells to arrays.
    Xs = Values2Array(Known_Xs)
    Ys = Values2Array(Known_Ys)
    
'
'   Check that the X_Value array is in monotonic ascending or descending order.
    bAscend = (Xs(2) > Xs(1))
    i = 2
    Do While i < nValues
        If (bAscend Eqv (Xs(i + 1) > Xs(i))) Then
            i = i + 1
        Else
            Interpolate = "#OrderX!"
            Exit Function
        End If
    Loop
    
    
    Interpolate = LinearInterpolate(X_Value, Xs, Ys)
    
End Function
    
Private Function LinearInterpolate _
    (X_Value As Variant, Known_Xs() As Variant, Known_Ys() As Variant) _
As Variant
'
'   Function to do linear interpolation within two arrays.
'
'   Written 07/06/2001 (J.L. Jechura).
'   Modified 10/24/2002 (JL Jechura) to split up the Excel specific code from the general
'       array code.
'
Dim iRow As Integer, Fraction As Double

'
'   Determine the row that starts to bracket the answer.
'   Determine the interpolated x_value.

    iRow = Locate(X_Value, Known_Xs)
    Fraction = (X_Value - Known_Xs(iRow)) / (Known_Xs(iRow + 1) - Known_Xs(iRow))
    LinearInterpolate = Known_Ys(iRow) + (Known_Ys(iRow + 1) - Known_Ys(iRow)) * Fraction
    
    End Function


Function TableInterpolation _
    (Row_Value As Variant, Col_Value As Variant, Row_Array As Object, Col_Array As Object, _
    Table As Object) _
As Variant
Attribute TableInterpolation.VB_Description = "Function to interpolate within a 2D Table with given Row_Array & Col_Array values."
'
'   Function to do linear interpolation in a 2D table.
'
'   Written 02/28/2001 (J.L. Jechura).
'
Dim i           As Integer
Dim iRow        As Integer
Dim iCol        As Integer
Dim Fraction    As Double
Dim Value(0 To 1) As Double
Dim ArrayValues() As Variant

'
'   Determine the column that starts to bracket the answer.
    If (IsArray(Col_Array)) Then
        ArrayValues = Values2Array(Col_Array)
        iCol = Locate(Col_Value, ArrayValues)
    Else
        TableInterpolation = "COLUMN ARRAY!"
        Exit Function
    End If
    
'
'   Determine the row that starts to bracket the answer.
    If (IsArray(Row_Array)) Then
        ArrayValues = Values2Array(Row_Array)
        iRow = Locate(Row_Value, ArrayValues)
    Else
        TableInterpolation = "ROW ARRAY!"
        Exit Function
    End If
    
'
'   Determine the interpolated values along the upper & lower edges of the region.
    Fraction = (Col_Value - Col_Array(iCol)) / (Col_Array(iCol + 1) - Col_Array(iCol))
    For i = 0 To 1
        Value(i) = Table(iRow + i, iCol) + _
            (Table(iRow + i, iCol + 1) - Table(iRow + i, iCol)) * Fraction
    Next i
        
'
'   Determine the fnal interpolated value from these upper & lower edge values.
    Fraction = (Row_Value - Row_Array(iRow)) / (Row_Array(iRow + 1) - Row_Array(iRow))
    TableInterpolation = Value(0) + (Value(1) - Value(0)) * Fraction
    
    End Function

Private Function Locate(X_Value As Variant, Known_Xs() As Variant) As Variant
'
'   Returns the index value in "known_xs" that precedes the given "x_value".  Bisection method
'   used.
'
'   Based on Fortran code in _Numerical Recipes in Fortran 77, 2nd ed._, WH Press, SA Teukolsky, WT Vetterling, & BP Flannery, 1992, pg. 111.
'
'   Written 08/31/2001 (JL Jechura).
'
Dim jFirst As Long, jLast As Long
Dim jLow As Long, jMid As Long, jUpper As Long
Dim bAscend As Boolean

'
' Initialize lower & upper limits.  Initialize logical flag for ascending data.
' Code using VB arrays.
    jFirst = LBound(Known_Xs)
    jLast = UBound(Known_Xs)
    
    jLow = jFirst - 1
    jUpper = jLast + 1
    bAscend = (Known_Xs(jLast) >= Known_Xs(jFirst))
    
    Do While ((jUpper - jLow) > 1)
        jMid = (jUpper + jLow) / 2
        If (bAscend = (X_Value >= Known_Xs(jMid))) Then
            jLow = jMid
        Else
            jUpper = jMid
        End If
    Loop

    Locate = WorksheetFunction.Max(jFirst, WorksheetFunction.Min(jLow, jLast - 1))

End Function

Private Function Values2Array(Original As Object) As Variant
'
'   Function to copy the values of an object to a single dimensioned array.
'
'   Written 10/24/2002 (JL Jechura).
'
Dim Values() As Variant
Dim nValues As Integer, i As Integer

    nValues = Original.Count
    ReDim Values(1 To nValues)
    For i = 1 To nValues
        Values(i) = Original(i)
    Next i
    
    Values2Array = Values
    
End Function
